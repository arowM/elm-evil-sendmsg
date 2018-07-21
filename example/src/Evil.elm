module Evil exposing (main)

import Dict exposing (Dict)
import Evil.SendMsg as SendMsg
import Html exposing (Html, div, text, span)
import Html.Attributes exposing (attribute, class)
import Html.Events as Events
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2)
import Process
import Random exposing (Generator)
import Task
import Time


-- APP


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { counter = 0
      , auto = False
      , talk = Nothing
      , goat = NormalGoat
      }
    , Cmd.none
    )



-- MODEL


type alias Model =
    { counter : Int
    , auto : Bool
    , talk : Maybe String
    , goat : Goat
    }


type Goat
    = NormalGoat
    | SpecialGoat


showGoat : Goat -> String
showGoat =
    toString



-- UPDATE


type Msg
    = UpdateTalk
    | SetTalk String
    | UpdateGoat
    | ToggleAuto
    | ShowOverlay


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTalk ->
            ( model
            , Random.generate SetTalk <| randomTalk
            )

        SetTalk talk ->
            ( { model
                | talk = Just talk
              }
            , Process.sleep (2 * Time.second)
                |> Task.attempt (\_ -> ShowOverlay)
            )

        UpdateGoat ->
            ( { model
                | goat = SpecialGoat
              }
            , Cmd.none
            )

        ToggleAuto ->
            ( { model
                | auto = not model.auto
              }
            , Cmd.none
            )

        ShowOverlay ->
            ( { model
                | counter = model.counter + 1
              }
            , Cmd.none
            )


randomTalk : Generator String
randomTalk =
    Random.int 3 10
        |> Random.andThen (\n -> Random.list n randomWord)
        |> Random.map (String.join " " << List.filterMap identity)


randomWord : Generator (Maybe String)
randomWord =
    Random.int 0 (Dict.size wordDict - 1)
        |> Random.map (\n -> Dict.get n wordDict)


wordDict : Dict Int String
wordDict =
    (Dict.fromList << List.indexedMap (,))
        [ "bleat"
        , "bl"
        , "b"
        , "bb"
        , "bleeeeeat"
        , "BLEEEEEEEEEAT!!!"
        , "bleeeat..."
        , "..."
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "wrapper"
        ]
        [ backgroundView model.goat
        , life model.counter
        , talkView model
        , SendMsg.when (model.counter >= 5) UpdateGoat
        ]


backgroundView : Goat -> Html Msg
backgroundView model =
    div
        [ class "background"
        , class <| "background-" ++ showGoat model
        ]
        []


life : Int -> Html Msg
life n =
    div
        [ class "life"
        ]
        [ div
            [ class "life_bar"
            , class <| "life_bar-" ++ toString n
            ]
            []
        , div
            [ class "life_icon"
            ]
            []
        ]


talkView : Model -> Html Msg
talkView model =
    div
        [ class "talk"
        , class <| "talk-" ++ showGoat model.goat
        ]
        <| if (model.talk /= Nothing) then
            [ lazy talkBody model.talk
            , overlay model
            , lazy autoButton model.auto
            ]
          else
            [ overlay model
            ]


talkBody : Maybe String -> Html Msg
talkBody model =
    div
        [ class "talk_body"
        ]
        [ span
            [ class "talk_body_text"
            ]
            [ text "Sakura-chan: "
            ]
        , span
            [ class "talk_body_text"
            , class "talk_body_text-main"
            ]
            [ text <| Maybe.withDefault "" model
            ]
        ]


overlay : Model -> Html Msg
overlay model =
    div
        [ class "overlay"
        , Events.onClick UpdateTalk
        ]
        [ case model.talk of
            Nothing ->
                overlayStartUp

            Just _ ->
                lazy2 overlayOnGame model.auto model.counter
        ]


overlayStartUp : Html Msg
overlayStartUp =
    span
        [ class "overlay_text-startUp"
        ]
        [ text "Click to Start!"
        ]


overlayOnGame : Bool -> Int -> Html Msg
overlayOnGame auto n =
    Keyed.node "div" []
        [ ( toString n
          , div
            [ class "overlay_text-next"
            ]
            [ if auto then
                SendMsg.onRenderThis UpdateTalk
              else
                text "Click to next"
            ]
          )
        ]


autoButton : Bool -> Html Msg
autoButton auto =
    div
        [ class "autoButton"
        , Events.onClick ToggleAuto
        , attribute "role" "checkbox"
        , attribute "aria-checked" <|
            if auto then
                "true"
            else
                "false"
        ]
        [ text "Auto"
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
