module Evil.SendMsg
    exposing
        ( onRenderThis
        , onChange
        , when
        )

{-| An evil library for Elm using bad hack to issue Msg on rendering a DOM.

⚠⚠⚠⚠⚠⚠⚠⚠🐐WARNING🐐⚠⚠⚠⚠⚠⚠⚠⚠

Make sure this library uses evil bad hack that could break TEA.

⚠⚠⚠⚠⚠⚠⚠⚠🐐WARNING🐐⚠⚠⚠⚠⚠⚠⚠⚠

@docs onRenderThis
@docs onChange
@docs when

-}

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Html.Keyed as Keyed
import Json.Decode as Json


{-| An evil view that sends `Msg` on rendering.
-}
onRenderThis : msg -> Html msg
onRenderThis msg =
    Html.img
        [ Attributes.src ""
        , Events.on "error" <| Json.succeed msg
        ]
        []


{-| An evil view that sends `Msg` on changing first argument.
-}
onChange : String -> msg -> Html msg
onChange str msg =
    Keyed.node "div"
        []
        [ ( str
          , onRenderThis msg
          )
        ]


{-| An evil view that sends `Msg` only when provided condition is `True`.
-}
when : Bool -> msg -> Html msg
when p msg =
    if p then
        onRenderThis msg
    else
        Html.text ""
