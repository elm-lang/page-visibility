effect module PageVisibility where { subscription = MySub } exposing
  ( Visibility(..)
  , isHidden, isVisible, visibility
  , visibilityChanges
  , onVisibilityChange
  )

{-|

# Page Visibility
@docs Visibility, visibility, isHidden, isVisible

# Changes
@docs visibilityChanges

# Low Level
@docs onVisibilityChange
-}

import Native.PageVisibility
import Process
import Task exposing (Task)



-- PAGE VISIBILITY


{-| Value describing whether the page is hidden or visible.
-}
type Visibility = Visible | Hidden


{-| Get the current page visibility.
-}
visibility : Task x Visibility
visibility =
  Task.map hiddenToVisibility isHidden


hiddenToVisibility : Bool -> Visibility
hiddenToVisibility hidden =
  if hidden then Hidden else Visible


{-| Is the page hidden?
-}
isHidden : Task x Bool
isHidden =
  Native.PageVisibility.isHidden


{-| Is the page visible?
-}
isVisible : Task x Bool
isVisible =
  Task.map not isHidden



-- SUBSCRIPTIONS


{-| Subscribe to any visibility changes. You will get updates about the current
visibility.
-}
visibilityChanges : (Visibility -> msg) -> Sub msg
visibilityChanges tagger =
  subscription (Tagger tagger)



type MySub msg
  = Tagger (Visibility -> msg)


subMap : (a -> b) -> MySub a -> MySub b
subMap func (Tagger tagger) =
  Tagger (tagger >> func)



-- EFFECT MANAGER


type alias State msg =
  Maybe
    { subs : List (MySub msg)
    , pid : Process.Id
    }


init : Task Never (State msg)
init =
  Task.succeed Nothing


onEffects : Platform.Router msg Bool -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router newSubs state =
  case (state, newSubs) of
    (Nothing, []) ->
      Task.succeed state

    (Nothing, _ :: _) ->
      Process.spawn (onVisibilityChange (Platform.sendToSelf router))
        |> Task.andThen (\pid -> Task.succeed (Just { subs = newSubs, pid = pid }))

    (Just {pid}, []) ->
      Process.kill pid
        |> Task.andThen (\_ -> Task.succeed Nothing)

    (Just {pid}, _ :: _) ->
      Task.succeed (Just { subs = newSubs, pid = pid })


onSelfMsg : Platform.Router msg Bool -> Bool -> State msg -> Task Never (State msg)
onSelfMsg router hidden state =
  case state of
    Nothing ->
      Task.succeed state

    Just {subs} ->
      let
        send (Tagger tagger) =
          Platform.sendToApp router (tagger (hiddenToVisibility hidden))
      in
        Task.sequence (List.map send subs)
          |> Task.andThen (\_ -> Task.succeed state)



-- LOW LEVEL


{-| A normal user should never need this. This should only be useful if you are
creating an effect manager that needs to track page visibility for some reason.
The boolean value is from calling `isHidden`.

This task never completes. Use `Process.spawn` and `Process.kill` to run it in
a separate process and kill it when it is no longer needed.
-}
onVisibilityChange : (Bool -> Task Never ()) -> Task x Never
onVisibilityChange =
  Native.PageVisibility.visibilityChange
