
class ToolbarViewModel : ViewModel {
    var activityInprogress = MutableLiveData(false)
    var backButtonVisible = MutableLiveData(false)
    var burgerButtonVisible = MutableLiveData(true)
    var leftButtonVisible = MutableLiveData(false)
    var rightButtonVisible = MutableLiveData(false)
}
