import Foundation

/**
 An error that occurs when calculating directions.
 */
public enum DirectionsError: LocalizedError {
    /**
     The server returned an empty response.
     */
    case noData
    
    case invalidInput(message: String?)
    
    /**
     The server returned a response that isn’t correctly formatted.
     */
    case invalidResponse
    
    /**
     No route could be found between the specified locations.
     
     Make sure it is possible to travel between the locations with the mode of transportation implied by the profileIdentifier option. For example, it is impossible to travel by car from one continent to another without either a land bridge or a ferry connection.
     */
    case unableToRoute
    
    /**
     The specified coordinates could not be matched to the road network.
     
     Try again making sure that your tracepoints lie in close proximity to a road or path.
     */
    case noMatches
    
    /**
     The request specifies too many coordinates.
     
     Try again with fewer coordinates.
     */
    case tooManyCoordinates
    
    /**
     A specified location could not be associated with a roadway or pathway.
     
     Make sure the locations are close enough to a roadway or pathway. Try setting the `Waypoint.coordinateAccuracy` property of all the waypoints to `nil`.
     */
    case unableToLocate
    
    /**
     Unrecognized profile identifier.
     
     Make sure the `DirectionsOptions.profileIdentifier` option is set to one of the predefined values, such as `DirectionsProfileIdentifier.automobile`.
     */
    case profileNotFound
    
    /**
     The request is too large.
     
     Try specifying fewer waypoints or giving the waypoints shorter names.
     */
    case requestTooLarge
    
    /**
     Too many requests have been made with the same access token within a certain period of time.
     
     Wait before retrying.
     */
    case rateLimited(rateLimitInterval: TimeInterval?, rateLimit: UInt?, resetTime: Date?)
    
    case unknown(response: URLResponse?, underlying: Error?, code: String?, message: String?)
    
    public var failureReason: String? {
        switch self {
        case .noData:
            return "The server returned an empty response."
        case let .invalidInput(message):
            return message
        case .invalidResponse:
            return "The server returned a response that isn’t correctly formatted."
        case .unableToRoute:
            return "No route could be found between the specified locations."
        case .noMatches:
            return "The specified coordinates could not be matched to the road network."
        case .tooManyCoordinates:
            return "The request specifies too many coordinates."
        case .unableToLocate:
            return "A specified location could not be associated with a roadway or pathway."
        case .profileNotFound:
            return "Unrecognized profile identifier."
        case .requestTooLarge:
            return "The request is too large."
        case let .rateLimited(rateLimitInterval: interval, rateLimit: limit, _):
            let intervalFormatter = DateComponentsFormatter()
            intervalFormatter.unitsStyle = .full
            guard let interval = interval, let limit = limit else {
                return "Too many requests."
            }
            let formattedInterval = intervalFormatter.string(from: interval) ?? "\(interval) seconds"
            let formattedCount = NumberFormatter.localizedString(from: NSNumber(value: limit), number: .decimal)
            return "More than \(formattedCount) requests have been made with this access token within a period of \(formattedInterval)."
        case let .unknown(_, underlying: error, _, message):
            return message
                ?? (error as NSError?)?.userInfo[NSLocalizedFailureReasonErrorKey] as? String
                ?? HTTPURLResponse.localizedString(forStatusCode: (error as NSError?)?.code ?? -1)
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .noData, .invalidInput, .invalidResponse:
            return nil
        case .unableToRoute:
            return "Make sure it is possible to travel between the locations with the mode of transportation implied by the profileIdentifier option. For example, it is impossible to travel by car from one continent to another without either a land bridge or a ferry connection."
        case .noMatches:
            return "Try again making sure that your tracepoints lie in close proximity to a road or path."
        case .tooManyCoordinates:
            return "Try again with 100 coordinates or fewer."
        case .unableToLocate:
            return "Make sure the locations are close enough to a roadway or pathway. Try setting the coordinateAccuracy property of all the waypoints to nil."
        case .profileNotFound:
            return "Make sure the profileIdentifier option is set to one of the provided constants, such as DirectionsProfileIdentifier.automobile."
        case .requestTooLarge:
            return "Try specifying fewer waypoints or giving the waypoints shorter names."
        case let .rateLimited(rateLimitInterval: _, rateLimit: _, resetTime: rolloverTime):
            guard let rolloverTime = rolloverTime else {
                return nil
            }
            let formattedDate: String = DateFormatter.localizedString(from: rolloverTime, dateStyle: .long, timeStyle: .long)
            return "Wait until \(formattedDate) before retrying."
        case let .unknown(_, underlying: error, _, _):
            return (error as NSError?)?.userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String
        }
    }
}

extension DirectionsError: Equatable {
    public static func == (lhs: DirectionsError, rhs: DirectionsError) -> Bool {
        switch (lhs, rhs) {
        case (.noData, .noData),
             (.invalidResponse, .invalidResponse),
             (.unableToRoute, .unableToRoute),
             (.noMatches, .noMatches),
             (.tooManyCoordinates, .tooManyCoordinates),
             (.unableToLocate, .unableToLocate),
             (.profileNotFound, .profileNotFound),
             (.requestTooLarge, .requestTooLarge):
            return true
        case let (.invalidInput(lhsMessage), .invalidInput(rhsMessage)):
            return lhsMessage == rhsMessage
        case (.rateLimited(let lhsRateLimitInterval, let lhsRateLimit, let lhsResetTime),
              .rateLimited(let rhsRateLimitInterval, let rhsRateLimit, let rhsResetTime)):
            return lhsRateLimitInterval == rhsRateLimitInterval
                && lhsRateLimit == rhsRateLimit
                && lhsResetTime == rhsResetTime
        case (.unknown(let lhsResponse, let lhsUnderlying, let lhsCode, let lhsMessage),
              .unknown(let rhsResponse, let rhsUnderlying, let rhsCode, let rhsMessage)):
            return lhsResponse == rhsResponse
                && type(of: lhsUnderlying) == type(of: rhsUnderlying)
                && lhsUnderlying?.localizedDescription == rhsUnderlying?.localizedDescription
                && lhsCode == rhsCode
                && lhsMessage == rhsMessage
        case (.noData, _),
             (.invalidResponse, _),
             (.unableToRoute, _),
             (.noMatches, _),
             (.tooManyCoordinates, _),
             (.unableToLocate, _),
             (.profileNotFound, _),
             (.requestTooLarge, _),
             (.invalidInput, _),
             (.rateLimited, _),
             (.unknown, _):
            return false
        }
    }
}

/**
 An error that occurs when encoding or decoding a type defined by the MapboxDirections framework.
 */
public enum DirectionsCodingError: Error {
    /**
     Decoding this type requires the `Decoder.userInfo` dictionary to contain the `CodingUserInfoKey.options` key.
     */
    case missingOptions
}
