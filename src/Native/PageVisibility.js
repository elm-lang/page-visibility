// setup
Elm.Native = Elm.Native || {};
Elm.Native.PageVisibility = Elm.Native.PageVisibility || {};

// definition
Elm.Native.PageVisibility.make = function(localRuntime) {
  'use strict';

  // attempt to short-circuit
  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.PageVisibility = localRuntime.Native.PageVisibility || {};
  if ('values' in localRuntime.Native.PageVisibility)
  {
    return localRuntime.Native.PageVisibility.values;
  }

  var prefix = '';

  if (typeof document.hidden === "undefined") {
    if (typeof document.mozHidden !== "undefined") {
      prefix = 'moz';
    }
    else if (typeof document.msHidden !== "undefined") {
      prefix = 'ms';
    }
    else if (typeof document.webkitHidden !== "undefined") {
      prefix = 'webkit';
    }
  }

  var NS = Elm.Native.Signal.make(localRuntime);

  var state = NS.input('visibilitychange', { ctor: 'Visible' });

  localRuntime.addListener([state.id], document, prefix + 'visibilitychange', function() {
    localRuntime.notify(state.id, {
      ctor: (document[prefix + 'hidden']) ? 'Hidden' : 'Visible'
    });
  });

  return localRuntime.Native.PageVisibility.values = {
    state: state
  };
};
