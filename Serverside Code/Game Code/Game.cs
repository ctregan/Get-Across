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
        public int positionX;
        public int positionY;
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
		// This method is called when an instance of your the game is created
		public override void GameStarted() {
            players = new Player[2];
            field = new Tile[10,10];
            numPlayers = 0;

			// anything you write to the Console will show up in the 
			// output window of the development server
			Console.WriteLine("Game is started: " + RoomId);
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
		public override void UserJoined(Player player) {
			// this is how you send a player a message
            //Send the player their player Number.
            if (numPlayers < players.Length)
            {
                player.Send("init", player.Id, player.ConnectUserId, "Tutorial_1");
                players[numPlayers] = player;
                Console.WriteLine("New Player " + player.Id);
                player.AP = 20;
                player.positionX = 0;
                player.positionY = 0;
                player.characterClass = "Novice";
                numPlayers++;
                // this is how you broadcast a message to all players connected to the game
                Broadcast("UserJoined", player.Id, player.positionX, player.positionY);
                //Update them on who is already in the game
                foreach (Player x in players)
                {
                    
                    if (x!= null && x != player)
                    {
                        Console.WriteLine("Sending Player " + player.Id + " Player " + x.Id + " Position (" + x.positionX + ", " + x.positionY + ")"); //debug
                        player.Send("UserJoined", x.Id, x.positionX, x.positionY);
                    }
                }
            }
            else
            {
                player.Send("full");
            }
		}

		// This method is called when a player leaves the game
		public override void UserLeft(Player player) {
			Broadcast("UserLeft", player.Id);
		}

		// This method is called when a player sends a message into the server code
		public override void GotMessage(Player player, Message message) {
			switch(message.Type) {
				// This is how you would set a players name when they send in their name in a 
				// "MyNameIs" message

                case "MyNameIs":
                    {
                        player.Name = message.GetString(0);
                        break;
                    }
                case "join":
                    {
                        joinGame(player);
                        break;
                    }
                case "move":
                    {
                        int messageX = message.GetInt(0);
                        int messageY = message.GetInt(1);
                        int xDistance = Math.Abs(messageX - player.positionX);
                        int yDistance = Math.Abs(messageY - player.positionY);
                        /*if ((xDistance > 1 || yDistance > 1) || (xDistance == 0 && yDistance == 0))
                        {
                            player.Send("invalidMove");
                            break;
                        }
                        else if (field[messageX, messageY].cost > player.AP)
                        {
                            player.Send("insufficientAP");
                            break;
                        }
                        else
                        {*/
                        player.positionX = player.positionX + messageX;
                        player.positionY = player.positionY + messageY;
                        Console.WriteLine("Player " + player.Id + " is moving to (" + player.positionX + ", " + player.positionY + ")"); //debug 
                        Broadcast("PlayerMove", player.Id, messageX, messageY);
                            //player.AP = player.AP - field[messageX, messageY].cost;
                        //}
                        break;
                    }
                case "playerInfo":
                    {
                        if (players[player.Id-1] == null)
                        {
                            player.Send("noSuchPlayer");
                        }
                        else
                        {
                            player.Send("playerInfo", players[player.Id - 1].positionX, players[player.Id - 1].positionY);
                        }
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
			}
		}

        private void joinGame(Player user) {
            

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
