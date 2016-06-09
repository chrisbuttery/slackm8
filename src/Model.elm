module Model exposing (..)


type alias Member =
  { id : String
  , team_id : String
  , name : String
  , real_name : String
  , avatar_sml : String
  , avatar_lrg : String
  }


type alias Group =
  { title : String
  , group : List Member
  }


type alias Model =
  { error : Bool
  , message : String
  , groups : List (List Member)
  , isLoading : Bool
  , limit : Int
  , team : Maybe (List Member)
  , title : String
  , token : String
  , success : Bool
  }


-- model

model : Model
model =
  { error = False
  , message = ""
  , groups = []
  , isLoading = False
  , limit = 1
  , team = Nothing
  , title = "Room"
  , token = ""
  , success = False
  }
