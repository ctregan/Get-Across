using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace GetAcross {

    //Player class. Each player that joins the game will have these attributes
	public class Player : BasePlayer {
		public string Name;
        public int level;
        public int AP;
        public int positionX;   // x tile position
        public int positionY;   // y tile position
        public string characterClass;
	}
    
    //Tile class. Each tile will have these attributes
    public class Tile
    {
        public int cost;
        public String type;
    }

	[RoomType("GetAcross")]
	public class GameCode : Game<Player> {
        private Player[] players;
        private int numPlayers;
        private Tile[,] field;
        private String levelKey;
        private String playerConnectUserId;
        //private int player.AP;       // server's variable to keep track of clientside player AP amount
        private String questID;    // id of the quest player is in
        DateTime startSessionTime, endSessionTime, lastSessionEndTime;
        String DateTimeFormat = "MM/dd/yyyy HH:mm:ss";

        // variables to keep track of player resources, map
        public int amountLumber = 0;
        public String questMap = "";

		// This method is called when an instance of your game is created
		public override void GameStarted() {
            players = new Player[2];
            field = new Tile[10,10];
            numPlayers = 0;
            levelKey = RoomData["key"];
            PreloadPlayerObjects = true;
            startSessionTime = DateTime.Now;

            if (levelKey.Contains("Tutorial"))
            {
               // Visible = false;
            }
			// anything you write to the Console will show up in the 
			// output window of the development server
			Console.WriteLine("Game is started: " + RoomId + "\nLevel Key: " + levelKey);

            /*
			// This is how you setup a timer
			AddTimer(delegate {
				// code here will code every 100th millisecond (ten times a second)
			}, 100);
			
			// Debug Example:
			// Sometimes, it can be very usefull to have a graphical representation
			// of the state of your game.
			// An easy way to accomplish this is to setup a timer to update the
			// debug view every 250th second (4 times a second).
			AddTimer(delegate {
				// This will cause the GenerateDebugImage() method to be called
				// so you can draw a grapical version of the game state.
				RefreshDebugView(); 
			}, 250);*/
		}

		// This method is called when the last player leaves the room, and it's closed down.
		public override void GameClosed() {
			Console.WriteLine("RoomId: " + RoomId);
		}

		// This method is called whenever a player joins the game
		public override void UserJoined(Player player)  {
			// this is how you send a player a message
            //Send the player their player Number.
            playerConnectUserId = player.ConnectUserId;
            if (numPlayers < players.Length)
            {             
                players[numPlayers] = player;
                Console.WriteLine("New Player " + player.Id);
                player.characterClass = "Novice";
                numPlayers++;

                // if player is not attached to a quest, give them a new quest ID
                PlayerIO.BigDB.Load("PlayerObjects", player.ConnectUserId,
                    delegate(DatabaseObject result)
                    {
                        // if player does not have a questID associated with it
                        // create new object in Quests db
                        if (!result.Contains("questID") || result.GetString("questID") == "noQuest")
                        {
                            // create new quest object
                            DatabaseObject newQuest = new DatabaseObject();

                            // create array for players playing this new quest object
                            DatabaseObject questPlayers = new DatabaseObject();

                            // create new object for this player and their quest data
                            DatabaseObject questPlayerData = new DatabaseObject();
                            questPlayerData.Set("positionX", 0);
                            questPlayerData.Set("positionY", 0);
                            questPlayerData.Set("AP", 20);

                            // add this player to players playing this quest
                            questPlayers.Set("numPlayers", 1);
                            questPlayers.Set(player.ConnectUserId, questPlayerData);
                            newQuest.Set("players", questPlayers);
                           
                            Console.WriteLine("questPlayers contents: " + questPlayers.ToString());
                            Console.WriteLine("Level key: " + levelKey);
                            //Add Static Map to Quest, to be updated later
                            PlayerIO.BigDB.Load("StaticMaps", levelKey, 
                                delegate(DatabaseObject staticMap)
                                {
                                    newQuest.Set("StaticMapKey", staticMap.Key);
                                    newQuest.Set("tileValues", staticMap.GetString("tileValues"));
                                    newQuest.Set("MonsterCount", staticMap.GetInt("MonsterCount"));
                                    if (staticMap.Contains("Monsters"))
                                    {
                                        DatabaseArray monsters = staticMap.GetArray("Monsters");
                                        DatabaseArray newMonsters = new DatabaseArray();
                                        for (int i = 1; i <= monsters.Count; i++)
                                        {
                                            DatabaseObject monster = new DatabaseObject();
                                            monster.Set("Type", monsters.GetObject(i - 1).GetString("Type"));
                                            monster.Set("xTile", monsters.GetObject(i - 1).GetInt("xTile"));
                                            monster.Set("yTile", monsters.GetObject(i - 1).GetInt("yTile"));
                                            monster.Set("AP", monsters.GetObject(i - 1).GetInt("AP"));
                                            newMonsters.Add(monster);
                                        }
                                        newQuest.Set("Monsters", newMonsters);
                                    }

                                    // add this quest object to Quests db
                                    PlayerIO.BigDB.CreateObject("NewQuests", null, newQuest,
                                        delegate(DatabaseObject addedQuest)
                                        {
                                            questID = addedQuest.Key;
                                            Console.WriteLine("made new questID!  new questID is: " + questID);
                                            // save new quest object's ID to this player to link them to the quest
                                            PlayerIO.BigDB.Load("PlayerObjects", player.ConnectUserId,
                                                delegate(DatabaseObject thisPlayer)
                                                {
                                                    thisPlayer.Set("questID", addedQuest.Key);
                                                    thisPlayer.Save();
                                                }
                                            );
                                            levelKey = addedQuest.Key;
                                            // tell client to initialize (board, monsters, player object & player sprite) with max AP amount
                                            player.Send("init", player.Id, player.ConnectUserId, levelKey, 20, staticMap.Key, null);
                                            //player.Send("AlertMessages", staticMap.Key);
                                    });
                                });
                           
                            // save positions in the serverside
                            player.positionX = player.positionY = 0;
                            player.AP = 20;
                        }

                        // else, this player has a questID saved
                        else
                        {
                            questID = result.GetString("questID");
                            levelKey = questID;
                            // obtain player's last position and save to serverside
                            PlayerIO.BigDB.Load("NewQuests", questID,
                                delegate(DatabaseObject questObject)
                                {
                                    String resources = null; // player's resources, to pass to client

                                    if (questObject != null)
                                    {
                                        // extract players playing this quest
                                        DatabaseObject playersInQuest = questObject.GetObject("players");
                                        DatabaseObject thisPlayer = playersInQuest.GetObject(player.ConnectUserId);
                                        player.positionX = thisPlayer.GetInt("positionX");
                                        player.positionY = thisPlayer.GetInt("positionY");
                                        int startAP = thisPlayer.GetInt("AP");
                                        if (thisPlayer.Contains("lastSessionEndTime"))
                                        {
                                            // figure out how much AP player should have based on how long they've been away
                                            lastSessionEndTime = thisPlayer.GetDateTime("lastSessionEndTime");
                                            //Console.WriteLine("last session end time : " + lastSessionEndTime.ToString(DateTimeFormat));
                                            int minutesPassedSinceLastPlay = (startSessionTime - lastSessionEndTime).Minutes;
                                            startAP += minutesPassedSinceLastPlay / 3;
                                            //Console.WriteLine("minutes passed: " + minutesPassedSinceLastPlay + ", amount of AP to add: " + (minutesPassedSinceLastPlay / 3) + ", starting AP: " + startAP);
                                            if (startAP > 20) startAP = 20;
                                            player.AP = startAP;
                                        }
                                        else player.AP = 20;

                                        // get information about player resources from db
                                        if (thisPlayer.Contains("resources"))
                                        {
                                            DatabaseObject resourcesObject = thisPlayer.GetObject("resources");
                                            Console.WriteLine("resources object: " + resourcesObject.ToString());
                                            if (resourcesObject.Contains("lumber"))
                                                resources += "Lumber:" + resourcesObject.GetInt("lumber");
                                            
                                            Console.WriteLine("resources string: " + resources);
                                        }
                                    }

                                    // tell client to initialize (board, monsters, player object & player sprite)
                                    player.Send("init", player.Id, player.ConnectUserId, levelKey, player.AP, questObject.GetString("StaticMapKey"), resources);
                                }
                            );
                        }
                    }
                );
               
            }
            else
            {
                player.Send("full");
            }

            Console.WriteLine("userJoined is done");
		}

		// This method is called when a player leaves the game
		public override void UserLeft(Player player) {
			Broadcast("UserLeft", player.Id);
            endSessionTime = DateTime.Now;
            Console.WriteLine("User session end!  Set end session time: " + endSessionTime.ToString(DateTimeFormat));
            //update player's end session time in the newQuest database
            PlayerIO.BigDB.Load("NewQuests", questID,
                delegate(DatabaseObject result)
                {
                    // if result is not null and contains something, save it into Quests db
                    if (result != null && result.Contains("players"))
                    {
                        // save quest map data
                        result.Set("tileValues", questMap);

                        Console.WriteLine("UserLeft result: " + result.ToString());
                        DatabaseObject players = result.GetObject("players");
                        if (players != null && players.Contains(playerConnectUserId))
                        {
                            DatabaseObject thisPlayer = players.GetObject(playerConnectUserId);

                            thisPlayer.Set("lastSessionEndTime", endSessionTime);
                            thisPlayer.Set("AP", player.AP);
                            thisPlayer.Set("positionX", player.positionX);
                            thisPlayer.Set("positionY", player.positionY);

                            // if resources exists, increment it; if not, create it
                            if (thisPlayer.Contains("resources"))
                            {
                                DatabaseObject resourceCount = thisPlayer.GetObject("resources");
                                resourceCount.Set("lumber", amountLumber);
                            }

                            else
                            {
                                DatabaseObject resourceCount = new DatabaseObject();
                                resourceCount.Set("lumber", amountLumber);
                                thisPlayer.Set("resources", resourceCount);
                            }
                        }

                        result.Save();
                    }
                }
            );
		}

		// This method is called when a player sends a message into the server code
		public override void GotMessage(Player player, Message message) {
			switch(message.Type) {

                // player has moved up, down, left, or right
                case "move":
                    {
                        int messageX = message.GetInt(0);
                        int messageY = message.GetInt(1);
                        Console.Write("Incoming Move Message from " + player.Id + " X Change: " + messageX + " Y Change: + " + messageY);
                        player.positionX = player.positionX + messageX;
                        player.positionY = player.positionY + messageY;
                        Console.WriteLine("Player " + player.Id + " is moving to (" + player.positionX + ", " + player.positionY + ")"); //debug 
                        Broadcast("PlayerMove", player.Id, messageX, messageY);
                        break;
                    }
                case "PlayerSetUp":
                    {
                        // this is how you broadcast a message to all players connected to the game
                        Broadcast("UserJoined", player.Id, player.positionX, player.positionY);
                        //Update them on who is already in the game
                        foreach (Player x in players)
                        {
                            if (x != null && x != player)
                            {
                                Console.WriteLine("Sending Player " + player.Id + " Player " + x.Id + " Position (" + x.positionX + ", " + x.positionY + ")"); //debug
                                player.Send("UserJoined", x.Id, x.positionX, x.positionY);
                            }
                        }
                        break;
                    }
                // client is asking for data about player to draw on the screen
                case "playerInfo":
                    {
                        if (players[player.Id-1] == null)
                            player.Send("noSuchPlayer");
                        else
                            player.Send("playerInfo", players[player.Id - 1].positionX, players[player.Id - 1].positionY, playerConnectUserId);
                        break;
                    }

                case "MapTileChanged":
                    {
                        int xTile = message.GetInt(0);
                        int yTile = message.GetInt(1);
                        int newTileType = message.GetInt(2);
                        Console.WriteLine("Map Tile Change From Player " + player.Id + " (" + xTile + "," + yTile + ") to type: " + newTileType);
                        Broadcast("MapTileChanged", player.Id, xTile, yTile, newTileType);
                        break;
                    }

                // update server's variables for this player stat
                case "updateStat":
                    {
                        String statType = message.GetString(0);
                        if (statType == "AP")
                        {
                            player.AP = message.GetInt(1);
                            Console.WriteLine("server: player's AP increased! " + player.AP);
                        }
                        else if (statType == "lumber")
                        {
                            amountLumber = message.GetInt(1);
                            Console.WriteLine("server: player's lumber increased! " + amountLumber);
                        }
                        break;
                    }
                case "win":
                    {
                        PlayerIO.BigDB.Load("StaticMaps", levelKey,
                            delegate(DatabaseObject result)
                            {
                                // todo: change these based on what you got in the level
                                int gainedxp = 100;
                                int gainedcoin = 100;

                                if (result != null)
                                {
                                    gainedxp = result.GetInt("XP", 0); //How much XP the Level was worth
                                    gainedcoin = result.GetInt("Coin", 0); //How mucg coin the level was worth
                                }

                                //Check to see if player completed Tutorial level, in which case update their tutorial value
                                if (player.PlayerObject.GetInt("tutorial") == 1)
                                {
                                    DatabaseArray abilities = new DatabaseArray();
                                    abilities.Add("Crafter_Bridge");
                                    player.PlayerObject.Set("abilities" ,abilities);
                                    player.PlayerObject.Set("tutorial", 2);
                                }
                                else if (player.PlayerObject.GetInt("tutorial") == 2)
                                {
                                    player.PlayerObject.Set("tutorial", 3);
                                }
                                else if (player.PlayerObject.GetInt("tutorial") == 3)
                                {
                                    player.PlayerObject.Set("tutorial", 4);
                                }

                                player.PlayerObject.Set("xp", player.PlayerObject.GetInt("xp", 0) + gainedxp);
                                player.PlayerObject.Set("coin", player.PlayerObject.GetInt("coin", 0) + gainedcoin);
                                player.PlayerObject.Save();
                                Broadcast("win", player.Id, gainedxp, gainedcoin);
                                
                            },
                            delegate(PlayerIOError error)
                            {
                                Console.WriteLine(error.ToString());
                            });
                        
                        // quest is finished; remove this quest from the table
                        // todo: what happens if another player is playing this quest?
                        PlayerIO.BigDB.DeleteKeys("NewQuests", questID, null);
                        Console.WriteLine("deleted newquest key");
                        PlayerIO.BigDB.Load("PlayerObjects", player.ConnectUserId,
                            delegate(DatabaseObject thisPlayer)
                            {
                                thisPlayer.Set("questID", "noQuest");
                                thisPlayer.Save();
                            }
                        );

                        break;
                    }

                // recieves one string that is the newly updated map; save to associated quest object
                case "QuestMapUpdate":
                    {
                        questMap = message.GetString(0);
                        /*player.GetPlayerObject(
                            delegate(DatabaseObject updatedPlayerObject){
                                PlayerIO.BigDB.Load("NewQuests", levelKey,
                                     delegate(DatabaseObject dbo)
                                        {
                                            dbo.Set("tileValues", message.GetString(0));
                                            dbo.Save();
                                        });
                            });*/
                        break;
                    }
                case "MonsterAPChange":
                    {
                        int newAp = message.GetInt(0);
                        int monsterIndex = message.GetInt(1);
                       /* PlayerIO.BigDB.Load("newQuests", levelKey,
                            delegate(DatabaseObject dbo)
                            {
                                DatabaseArray monsters = dbo.GetArray("Monsters");
                                monsters.GetObject(monsterIndex).Set("AP", newAp);
                            */
                        //CHARLIE TO DO - Make this data reflected in the database too.
                        Broadcast("MonsterAPChange", player.Id, newAp, monsterIndex);
                        break;
                    }
			}
		}

		Point debugPoint;

		// This method get's called whenever you trigger it by calling the RefreshDebugView() method.
		public override System.Drawing.Image GenerateDebugImage() {
			// we'll just draw 400 by 400 pixels image with the current time, but you can
			// use this to visualize just about anything.
			var image = new Bitmap(400,400);
			using(var g = Graphics.FromImage(image)) {
				// fill the background
				g.FillRectangle(Brushes.Blue, 0, 0, image.Width, image.Height);

				// draw the current time
				g.DrawString(DateTime.Now.ToString(), new Font("Verdana",20F),Brushes.Orange, 10,10);

				// draw a dot based on the DebugPoint variable
				g.FillRectangle(Brushes.Red, debugPoint.X,debugPoint.Y,5,5);
			}
			return image;
		}

		// During development, it's very usefull to be able to cause certain events
		// to occur in your serverside code. If you create a public method with no
		// arguments and add a [DebugAction] attribute like we've down below, a button
		// will be added to the development server. 
		// Whenever you click the button, your code will run.
		[DebugAction("Play", DebugAction.Icon.Play)]
		public void PlayNow() {
			Console.WriteLine("The play button was clicked!");
		}

		// If you use the [DebugAction] attribute on a method with
		// two int arguments, the action will be triggered via the
		// debug view when you click the debug view on a running game.
		[DebugAction("Set Debug Point", DebugAction.Icon.Green)]
		public void SetDebugPoint(int x, int y) {
			debugPoint = new Point(x,y);
		}
	}
}
