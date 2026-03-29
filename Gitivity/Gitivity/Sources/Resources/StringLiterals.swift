import Foundation

enum StringLiterals {
    enum Feed {
        static let title = "활동"
        static let noActivity = "활동 없음"
        static let noActivityDescription = "최근 GitHub 활동이 없습니다."
        static let errorOccurred = "오류 발생"
        static let retry = "다시 시도"
    }

    enum Profile {
        static let title = "프로필"
        static let activityClassification = "활동 분류"
        static let contributionActivity = "기여 활동"
        static let last30Days = "최근 30일"
    }

    enum Stats {
        static let commits = "커밋"
        static let pr = "PR"
        static let repos = "레포"
    }

    enum AI {
        static let summaryLabel = "✦ AI 요약"
        static let disclaimer = "AI가 생성한 요약입니다"
        static let unavailableTitle = "Apple Intelligence\n필요"
        static let unavailableDescription = "Gitivity는 온디바이스 AI를 사용하여\nGitHub 활동을 요약합니다.\n\n이 기능을 사용하려면\nApple Intelligence가 필요합니다."
        static let enableInSettings = "설정에서 활성화하기"
        static let deviceRequirement = "iPhone 15 Pro 이상 기기에서\n사용할 수 있습니다"
    }

    enum Settings {
        static let title = "설정"
        static let aiModel = "AI 모델"
        static let aiModelValue = "Foundation"
        static let privacyPolicy = "개인정보 처리방침"
        static let appInfo = "앱 정보"
        static let appVersion = "1.0.0"
        static let sectionAI = "AI"
        static let sectionGeneral = "일반"
        static let sectionAccount = "계정"
        static let signOut = "로그아웃"
        static let deleteAccount = "계정 삭제"
        static let deleteAccountWarning = "모든 데이터가 삭제됩니다"
        static let deleteAccountConfirm = "계정을 삭제하시겠습니까?"
        static let deleteButton = "삭제"
        static let deleteAccountDetail = "Keychain 토큰이 삭제되고 로그아웃됩니다. 이 작업은 되돌릴 수 없습니다."
    }

    enum Onboarding {
        static let pageTitle = "내가 만든 것을\n이해하는 방법"
        static let pageDescription = "AI가 커밋과 PR을\n사람의 말로 요약해줍니다"
        static let timelineTitle = "레포별 타임라인"
        static let timelineDescription = "최근 작업한 레포를\n활동 분류와 함께 확인"
        static let onDeviceAI = "온디바이스 AI"
        static let dataPrivacy = "데이터가 기기를 떠나지 않습니다"
        static let skip = "건너뛰기"
        static let signInWithGitHub = "GitHub로 시작하기"
        static let privacyConsent = "계속하면 개인정보 처리방침에 동의하는 것으로 간주됩니다."
    }

    enum Tab {
        static let feed = "피드"
        static let profile = "프로필"
    }

    enum Badge {
        static let pullRequest = "PULL REQUEST"
        static let merged = "MERGED"
        static let commit = "COMMIT"
    }
}
