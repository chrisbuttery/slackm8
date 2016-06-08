#slackm8

_slackm8_ will randomly shuffle & split a team into groups & invite users to Slack channels.  
Written in [elm-lang](http://elm-lang.org/).

####[video demo](https://cloudup.com/ceqHFQ7HUJN)

![alt tag](https://github.com/chrisbuttery/slackm8/blob/master/slackm8.png)

### Why?

This specific use case is handy approach to grouping random members together
for a catch up in a specific channel. It was something my workplace promoted
as a way of building team communication skills.

This app was created automate the process of a user specifically generating channels and inviting random users. Plus I wanted to build another thing with [elm](http://elm-lang.org/).

## Getting started

```bash
% git clone git@github.com:chrisbuttery/slackm8.git
% cd slackm8
% open dist/index.html
```

## Slack API authorization test token

The best way to try this example out is to grab an API authorization test token for your slack team. https://api.slack.com/web.

This will allow _slackm8_ to make 3 types of http requests to your slack team.

* [users.list](https://api.slack.com/methods/users.list): Listing existing users
* [channels.create](https://api.slack.com/methods/channels.create): Creating a channel
* [channels.invite](https://api.slack.com/methods/channels.invite): Inviting a User to a Channel

_slackm8_ will store your test token as 'slackm8Model' in localStorage along with the rest of the model. Your token is only accessed from localStorage or the model directly.


## TIL

Here are just a few things I learnt along the way.

#### Decoding JSON objects.
Decoding JSON objects seemed a bit daunting to me. I think it's because you have to already know the structure that's going to be returned before you can attempt to decode it. You can't just look debug the response like you can in JS.

To get familiar with docoding various JSON structures in elm, [I created this sandbox](https://github.com/chrisbuttery/elm-simple-json-decoding).

#### Currying Http Task

I needed to perform specific Http Tasks in order, such as creating a channel and then populating this channel with users. This meant both tasks to create the room and populate it needed to have the same data.

Once I had my 'group' of users I passed them to my `createRoom` request. I could then partially apply the `CreateRoomsSuccess` Task with the sames users. This meant when `CreateRoomsSuccess` was handled at a later stage it had access to the same data.
Thank you [Chad Gilbert](https://github.com/freakingawesome).

```
createRoom : Group -> Cmd Msg
createRoom group =
  Task.perform
    CreateRoomsFail
    (CreateRoomsSuccess group.users)
    (Http.post
      decodeCreateRoomResponse
      ("https://some_api?room=" ++ group.title)
      Http.empty
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ...
    CreateRoomsSuccess users roomID ->
      model ! List.map (addUser roomID << .name) users
    ...
```

#### Splitting a list into a list or multiple lists

I won't lie. This continues to blow my mind.  
An example of what I had and wanted.

```
test = [1,2,3,4,5]

// desired output [[1,2], [2,3], [5]]
```

[I've commented on how I understand this function to work](https://github.com/chrisbuttery/slackm8/blob/master/src/Split.elm). I could have gotten it awfully wrong, so I'm happy for anyone to correct me.


## Development

Source files located in `/src`

```bash
% npm install && elm package install -y
% npm run build
```

## Todo

- [ ] On select event, get selected option value and not selectedIndex
- [ ] Add nicer styling to everything because I've literally done the bare minimum for this demo
- [ ] Add nicer UI interactions

## Acknowledgements

A great lot of thanks goes to [Rob Hoelz](https://github.com/hoelzro) and [Chad Gilbert](https://github.com/freakingawesome) for their wealth of Elm knowledge.

Thanks also goes to [Luke Westby](https://github.com/lukewestby) for creating this [elm-drum-machine](https://github.com/lukewestby/elm-drum-machine) project, which gave me tips on logging.

> [chrisbuttery.com](http://chrisbuttery.com) &nbsp;&middot;&nbsp;
> GitHub [@chrisbuttery](https://github.com/chrisbuttery) &nbsp;&middot;&nbsp;
> Twitter [@buttahz](https://twitter.com/buttahz) &nbsp;&middot;&nbsp;
> elm-lang slack [@butters](http://elmlang.herokuapp.com/)
