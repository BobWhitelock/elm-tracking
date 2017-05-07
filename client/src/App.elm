module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import RemoteData exposing (WebData, RemoteData(..))
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


---- MODEL ----


type alias Model =
    { items : WebData (List Item)
    , itemForm : ItemForm
    }


type alias Item =
    { id : String
    , name : String
    }


type alias ItemForm =
    { name : String }


decodeItems : Decoder (List Item)
decodeItems =
    (Decode.field "data"
        (Decode.list (decodeItemWithinData))
    )


decodeItem : Decoder Item
decodeItem =
    Decode.field "data" decodeItemWithinData


decodeItemWithinData : Decoder Item
decodeItemWithinData =
    Decode.map2
        Item
        (Decode.field "id" Decode.string)
        (Decode.at [ "attributes", "name" ] Decode.string)


encodeItemForm : ItemForm -> Value
encodeItemForm itemForm =
    Encode.object
        [ ( "data"
          , (Encode.object
                [ ( "type", (Encode.string "items") )
                , ( "attributes"
                  , Encode.object
                        [ ( "name", (Encode.string itemForm.name) )
                        ]
                  )
                ]
            )
          )
        ]


init : ( Model, Cmd Msg )
init =
    ( { items = Loading
      , itemForm = ItemForm ""
      }
    , getItems
    )



---- UPDATE ----


type Msg
    = ItemsResponse (WebData (List Item))
    | CreateItemName String
    | CreateItem
    | CreateItemResponse (Result Http.Error Item)


getItems : Cmd Msg
getItems =
    Http.get itemsUrl decodeItems
        |> RemoteData.sendRequest
        |> Cmd.map ItemsResponse


createItemRequest : Model -> Cmd Msg
createItemRequest model =
    Http.send CreateItemResponse <|
        (apiRequest "POST"
            itemsUrl
            (encodeItemForm model.itemForm
                |> Http.jsonBody
            )
            decodeItem
        )


apiRequest : String -> String -> Http.Body -> Decoder a -> Http.Request a
apiRequest method url body decoder =
    Http.request
        { method = method
        , headers =
            [ Http.header "Content-Type" "application/vnd.api+json"
            , Http.header "Accept" "application/vnd.api+json"
            ]
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


itemsUrl : String
itemsUrl =
    apiUrl ++ "/items"


apiUrl : String
apiUrl =
    "http://localhost"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ItemsResponse response ->
            ( { model | items = response }, Cmd.none )

        CreateItemName name ->
            ( { model
                | itemForm = ItemForm name
              }
            , Cmd.none
            )

        CreateItem ->
            ( model, createItemRequest model )

        CreateItemResponse (Ok item) ->
            let
                newItems =
                    RemoteData.map2 (++) model.items (Success [ item ])
            in
                ( { model
                    | items = newItems
                    , itemForm = ItemForm ""
                  }
                , Cmd.none
                )

        CreateItemResponse (Err error) ->
            -- TODO error handling
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        itemForm =
            model.itemForm
    in
        case model.items of
            NotAsked ->
                text "Initializing..."

            Loading ->
                text "Loading..."

            Failure error ->
                text ("Error: " ++ toString error)

            Success items ->
                itemsView items itemForm


itemsView : List Item -> ItemForm -> Html Msg
itemsView items itemForm =
    let
        itemDivs =
            List.map itemView items
    in
        div
            []
            (itemDivs ++ [ itemFormView itemForm ])


itemView : Item -> Html Msg
itemView item =
    div [] [ text item.name ]


itemFormView : ItemForm -> Html Msg
itemFormView itemForm =
    div []
        [ input
            [ type_ "text"
            , placeholder "Name"
            , onInput CreateItemName
            ]
            []
        , button [ onClick CreateItem ] [ text "Create" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }
