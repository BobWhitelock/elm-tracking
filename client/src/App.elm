module App exposing (..)

import Html exposing (..)
import Http
import RemoteData exposing (WebData, RemoteData(..))
import Json.Decode as Decode exposing (Decoder)


---- MODEL ----


type alias Model =
    { items : WebData (List Item) }


type alias Item =
    { name : String
    }


decodeItems : Decoder (List Item)
decodeItems =
    (Decode.field "data"
        (Decode.list (decodeItem))
    )


decodeItem : Decoder Item
decodeItem =
    Decode.map
        Item
        (Decode.at [ "attributes", "name" ] Decode.string)


init : ( Model, Cmd Msg )
init =
    ( { items = Loading }, getItems )



---- UPDATE ----


type Msg
    = ItemsResponse (WebData (List Item))


getItems : Cmd Msg
getItems =
    let
        itemsUrl =
            apiUrl ++ "/items"
    in
        Http.get itemsUrl decodeItems
            |> RemoteData.sendRequest
            |> Cmd.map ItemsResponse


apiUrl : String
apiUrl =
    "http://localhost:4000"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ItemsResponse response ->
            ( { model | items = response }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.items of
        NotAsked ->
            text "Initializing..."

        Loading ->
            text "Loading..."

        Failure error ->
            text ("Error: " ++ toString error)

        Success items ->
            div [] (List.map viewItem items)


viewItem : Item -> Html Msg
viewItem item =
    div [] [ text item.name ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }
