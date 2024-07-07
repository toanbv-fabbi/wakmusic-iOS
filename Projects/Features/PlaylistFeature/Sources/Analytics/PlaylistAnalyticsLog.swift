import LogManager

enum PlaylistAnalyticsLog: AnalyticsLogType {
    case viewPage(pageName: String)
    case clickLockButton(id: String)
    case clickPlaylistEditButton
    case clickPlaylistShareButton
    case clickPlaylistCameraButton
    case clickPlaylistDefaultImageButton
    case clickPlaylistCustomImageButton
    case clickPlaylistPlayButton(type: String, key: String)
    case clickPlaylistSubscriptionButton(key: String)
}