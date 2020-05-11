import NimQml

# Probably all QT classes will look like this:
QtObject:
  type ApplicationLogic* = ref object of QObject
    app: QApplication
    callResult: string
    accountResult: string
    sendMessage: proc (msg: string):  string
    # chats: seq[ChatView]

  # Constructor
  proc newApplicationLogic*(app: QApplication, sendMessage: proc): ApplicationLogic =
    new(result)
    result.app = app
    result.sendMessage = sendMessage
    result.callResult = "Use this tool to call JSONRPC methods"
    result.setup()

  # ¯\_(ツ)_/¯ dunno what is this
  proc setup(self: ApplicationLogic) =
    # discard status.onMessage(self.onMessage)
    self.QObject.setup

  # ¯\_(ツ)_/¯ seems to be a method for garbage collection
  proc delete*(self: ApplicationLogic) =
    self.QObject.delete

  # Read more about slots and signals here: https://doc.qt.io/qt-5/signalsandslots.html

  # This is an EventHandler
  proc onExitTriggered(self: ApplicationLogic) {.slot.} =
    self.app.quit

  # Accesors
  proc callResult*(self: ApplicationLogic): string {.slot.} =
    result = self.callResult

  proc callResultChanged*(self: ApplicationLogic, callResult: string) {.signal.}

  proc setCallResult(self: ApplicationLogic, callResult: string) {.slot.} =
    if self.callResult == callResult: return
    self.callResult = callResult
    self.callResultChanged(callResult)

  proc `callResult=`*(self: ApplicationLogic, callResult: string) = self.setCallResult(callResult)

  # Binding between a QML variable and accesors is done here
  QtProperty[string] callResult:
    read = callResult
    write = setCallResult
    notify = callResultChanged

  proc onSend*(self: ApplicationLogic, inputJSON: string) {.slot.} =
    self.setCallResult(self.sendMessage(inputJSON))
    echo "Done!: ", self.callResult

  # proc onMessage*(self: ApplicationLogic, message: string) {.slot.} =
  #   self.setCallResult(message)
  #   echo "Received message: ", message

  proc accountResultChanged*(self: ApplicationLogic, callResult: string) {.signal.}

  proc accountResult*(self: ApplicationLogic): string {.slot.} =
    result = self.accountResult

  proc setAccountResult(self: ApplicationLogic, accountResult: string) {.slot.} =
    if self.accountResult == accountResult: return
    self.accountResult = accountResult
    self.accountResultChanged(accountResult)

  QtProperty[string] accountResult:
    read = accountResult
    write = setAccountResult
    notify = callResultChanged

  # This class has the metaObject property available which lets 
  # access all the QProperties which are stored as QVariants
