//
//  LocationManager.swift
//  死了么
//
//  Created by Claude on 2026/1/16.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Location Error

enum LocationError: Error, LocalizedError {
    case permissionDenied
    case timeout
    case failed(Error)
    case unavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "位置权限被拒绝，请在设置中允许访问位置信息"
        case .timeout:
            return "获取位置超时，请检查网络连接或稍后重试"
        case .failed(let error):
            return "获取位置失败：\(error.localizedDescription)"
        case .unavailable:
            return "位置服务不可用"
        }
    }
}

// MARK: - Location Manager

class LocationManager: NSObject, ObservableObject {

    // MARK: - Singleton

    static let shared = LocationManager()

    // MARK: - Properties

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading = false

    private let locationManager = CLLocationManager()
    private var locationCompletion: ((Result<CLLocation, LocationError>) -> Void)?
    private var timeoutTimer: Timer?
    private let timeoutInterval: TimeInterval = 10.0 // 10秒超时

    // MARK: - Initialization

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Methods

    /// 请求位置权限
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// 获取当前位置
    func requestCurrentLocation(completion: @escaping (Result<CLLocation, LocationError>) -> Void) {
        // 检查权限
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            // 还未请求权限，先请求
            locationCompletion = completion
            requestPermission()
            return

        case .restricted, .denied:
            completion(.failure(.permissionDenied))
            return

        case .authorizedWhenInUse, .authorizedAlways:
            break

        @unknown default:
            completion(.failure(.unavailable))
            return
        }

        // 保存回调
        locationCompletion = completion
        isLoading = true

        // 开始定位
        locationManager.startUpdatingLocation()

        // 设置超时定时器
        timeoutTimer?.invalidate()
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false) { [weak self] _ in
            self?.handleTimeout()
        }
    }

    /// 反地理编码：坐标 -> 地址
    func reverseGeocode(latitude: Double, longitude: Double, completion: @escaping (Result<String, LocationError>) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(.failed(error)))
                return
            }

            guard let placemark = placemarks?.first else {
                completion(.failure(.unavailable))
                return
            }

            // 拼接地址
            var addressComponents: [String] = []

            if let country = placemark.country {
                addressComponents.append(country)
            }
            if let administrativeArea = placemark.administrativeArea {
                addressComponents.append(administrativeArea)
            }
            if let locality = placemark.locality {
                addressComponents.append(locality)
            }
            if let subLocality = placemark.subLocality {
                addressComponents.append(subLocality)
            }
            if let thoroughfare = placemark.thoroughfare {
                addressComponents.append(thoroughfare)
            }
            if let subThoroughfare = placemark.subThoroughfare {
                addressComponents.append(subThoroughfare)
            }

            let address = addressComponents.joined(separator: "")
            completion(.success(address))
        }
    }

    /// 地理编码：地址 -> 坐标
    func geocode(address: String, completion: @escaping (Result<CLLocationCoordinate2D, LocationError>) -> Void) {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(.failure(.failed(error)))
                return
            }

            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                completion(.failure(.unavailable))
                return
            }

            completion(.success(location.coordinate))
        }
    }

    // MARK: - Private Methods

    private func handleTimeout() {
        locationManager.stopUpdatingLocation()
        isLoading = false

        if let completion = locationCompletion {
            completion(.failure(.timeout))
            locationCompletion = nil
        }
    }

    private func handleSuccess(_ location: CLLocation) {
        timeoutTimer?.invalidate()
        locationManager.stopUpdatingLocation()
        isLoading = false

        if let completion = locationCompletion {
            completion(.success(location))
            locationCompletion = nil
        }
    }

    private func handleFailure(_ error: LocationError) {
        timeoutTimer?.invalidate()
        locationManager.stopUpdatingLocation()
        isLoading = false

        if let completion = locationCompletion {
            completion(.failure(error))
            locationCompletion = nil
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        // 如果权限被授予且有待处理的回调，继续获取位置
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            if let completion = locationCompletion {
                requestCurrentLocation(completion: completion)
            }
        } else if authorizationStatus == .denied || authorizationStatus == .restricted {
            handleFailure(.permissionDenied)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // 验证位置的准确性
        if location.horizontalAccuracy > 0 {
            handleSuccess(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                handleFailure(.permissionDenied)
            default:
                handleFailure(.failed(error))
            }
        } else {
            handleFailure(.failed(error))
        }
    }
}
