import Foundation

enum Gender: Int {
    case FeMale = 0
    case Male = 1
    case Other = 2
}

enum MediaType: Int {
    case Image = 0
    case Video = 1
}

enum ProfileTab: Int {
    case Profile = 0
    case Frame = 1
    case AddUser = 2
}

enum ProfileDataType: Int {
    case Header = 0
    case ProfileDetail = 1
    case ProfileBottom = 2
    case FrameDetail = 3
    case AddUser = 4
    case UserInFrame = 5
}

enum UserRole: Int {
    case Owner = 0
    case Parent = 1
    case Brother = 2
    case Lover = 3
    case Related = 4
    case Friend = 5
}
