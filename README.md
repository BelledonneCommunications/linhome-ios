
// Linhome app
 
- When running from xcode after new commits - expected to see build "cancelled" as script update version, running build another time kae it work
- To see the console messages with phone connected : sudo log stream --level debug (Console App will show <private> tags)

- Compilation error : 
Pod build serttings for swift SVG -> 2

You can try SWIFT_INSTALL_OBJC_HEADER = NO, it works for me (in the pod build sttings for swift SVG)

//TODO CD
- Explain SwiftSVG vs PocketSVG vs fallback
