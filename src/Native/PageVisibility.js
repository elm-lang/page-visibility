// import Native.Scheduler, Utils //

var _elm_lang$page_visibility$Native_PageVisibility = function() {


// sort out the prefixes

var hidden, change;
if (typeof document.hidden !== 'undefined')
{
	hidden = 'hidden';
	change = 'visibilitychange';
}
else if (typeof document.mozHidden !== 'undefined')
{
	hidden = 'mozHidden';
	change = 'mozvisibilitychange';
}
else if (typeof document.msHidden !== 'undefined')
{
	hidden = 'msHidden';
	change = 'msvisibilitychange';
}
else if (typeof document.webkitHidden !== 'undefined')
{
	hidden = 'webkitHidden';
	change = 'webkitvisibilitychange';
}


// actually provide functionality

function visibilityChange(toTask)
{
	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {

		function performTask()
		{
			_elm_lang$core$Native_Scheduler.rawSpawn(toTask(document[hidden]));
		}

		document.addEventListener(change, performTask);

		return function()
		{
			document.removeEventListener(change, performTask);
		};
	});
}

var isHidden = _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
	callback(_elm_lang$core$Native_Scheduler.succeed(document[hidden]));
});


return {
	visibilityChange: visibilityChange,
	isHidden: isHidden
};

}();
