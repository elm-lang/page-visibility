module PageVisibility where

{-| Bindings for the [PageVisiblity API][page-visibility]

[page-visibility]: https://developer.mozilla.org/en-US/docs/Web/API/Page_Visibility_API

# Visibility state
@docs State, state

# State flags
@docs hidden, visible

-}

import Native.PageVisibility


{-| Page visibility can have two states, either visible or hidden.

The state will be `Hidden` whenever the current tab is not the active tab or
browser window is in the background.

The state will be 'Visible' when the page is the main browser window and it is
visible (not minimized).
-}
type State
    = Hidden
    | Visible


{-| Current page visibility state
-}
state : Signal State
state =
  Native.PageVisibility.state


{-| Page is hidden
-}
hidden : Signal Bool
hidden =
  Signal.map ((==) Hidden) state

{-| Page is visible
-}
visible : Signal Bool
visible =
  Signal.map ((==) Visible) state
