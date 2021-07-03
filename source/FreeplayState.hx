package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 2;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var wiiCursor:FlxSprite;
	var letter:FlxSprite;
	var bigLetter:FlxSprite;
	public static var addedGodEater:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var menuCol:FlxSprite;
	var bg:FlxSprite;
	var cmd_screen:FlxSprite;
	var cmd_text:FlxText;

	var hb_text_small:FlxSprite;
	var hb_bg:FlxSprite;
	var rot:Float = 0;

	var hb_big_border:FlxSprite;
	var hb_big_bg:FlxSprite;
	var hb_big_text:FlxSprite;
	var hb_flash:FlxSprite;

	var hb_water:FlxSprite;
	var hb_water_back:FlxSprite;

	var hb_step:Int = 0;

	var hb_big_size:Array<Float> = [100, 100];

	override function create()
	{
		Main.god = false;
		wiiCursor = new FlxSprite(0, 0).loadGraphic(Paths.image('wii_cursor'));
		wiiCursor.updateHitbox();
		cursorOWidth = wiiCursor.width;
		cursorSize = cursorOWidth;

		letter = new FlxSprite(0, 0).loadGraphic(Paths.image('letterbomb'));
		letter.updateHitbox();
		letter.setGraphicSize(80);
		letter.x = FlxG.width - 163;
		letter.y = FlxG.height - 147;
		letter.scrollFactor.set();

		hb_bg = new FlxSprite(0, 0).loadGraphic(Paths.image('hb_bg'));
		hb_bg.scrollFactor.set();
		hb_bg.alpha = 0;
		hb_bg.antialiasing = true;

		hb_text_small = new FlxSprite(FlxG.width - 1280 + 100, 0).loadGraphic(Paths.image('hb_text_small'));
		hb_text_small.scrollFactor.set();
		hb_text_small.alpha = 0;

		bigLetter = new FlxSprite(0, 0).loadGraphic(Paths.image('letterbomb'));
		bigLetter.scrollFactor.set();
		bigLetter.screenCenter(X);
		bigLetter.y = -600;
		bigLetter.updateHitbox();

		cmd_screen = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		cmd_screen.scrollFactor.set();
		cmd_screen.alpha = 0;
		
		cmd_text = new FlxText(10, 10, 0, '', 20);
		cmd_text.scrollFactor.set();
		cmd_text.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		if (!FlxG.save.data.showLetter)
		{
			letter.alpha = 0;
		}
		if (FlxG.save.data.wii >= 1)
		{
			letter.alpha = 0;
			hb_text_small.alpha = 1;
			hb_bg.frames = Paths.getSparrowAtlas('hb_files/hb_sc_bg');
			hb_bg.animation.addByPrefix('idle', 'water bitmap animation', 15);
			hb_bg.animation.play('idle');
			hb_bg.x = FlxG.width - 1280 + 100;
			hb_bg.y = 61;

			hb_big_border = new FlxSprite(100, 61).loadGraphic(Paths.image('hb_files/hb_big_border'));
			hb_big_border.scrollFactor.set();
			hb_big_border.alpha = 0;
			hb_big_border.setGraphicSize(260, 142);
			hb_big_border.antialiasing = true;
			hb_big_border.updateHitbox();

			hb_big_bg = new FlxSprite(100, 61).loadGraphic(Paths.image('hb_files/hb_big_bg'));
			hb_big_bg.scrollFactor.set();
			hb_big_bg.alpha = 0;
			hb_big_bg.setGraphicSize(260, 142);
			hb_big_bg.antialiasing = true;
			hb_big_bg.updateHitbox();

			hb_big_size = [260, 142];

			hb_water_back = new FlxSprite(0, 720).loadGraphic(Paths.image('hb_files/water_back'));
			hb_water_back.scrollFactor.set();
			hb_water_back.alpha = 0;

			hb_water = new FlxSprite(0, 720).loadGraphic(Paths.image('hb_files/water'));
			hb_water.scrollFactor.set();
			hb_water.alpha = 0;

			hb_big_text = new FlxSprite(0, 0).loadGraphic(Paths.image('hb_files/hb_big_text'));
			hb_big_text.scrollFactor.set();
			hb_big_text.alpha = 0;

			hb_flash = new FlxSprite(0, 0).loadGraphic(Paths.image('hb_files/hb_big_bg'));
			hb_flash.alpha = 0;
			hb_flash.scrollFactor.set();
		}
		/*
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			songs.push(new SongMetadata(initSonglist[i], 1, 'gf'));
		}
		*/

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

			addWeek(['Power-Link', 'Revenge', 'Final-destination'], 1, ['dad', 'matt', 'both']);

		// LOAD MUSIC

		// LOAD CHARACTERS

		menuCol = new FlxSprite().loadGraphic(Paths.image('menuColor'));
		//menuCol.setGraphicSize(FlxG.width);
		menuCol.updateHitbox();
		menuCol.screenCenter();
		bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		//bg.setGraphicSize(FlxG.width);
		bg.updateHitbox();
		bg.screenCenter();
		bg.x = FlxG.width - 1280;
		bg.y = FlxG.height - 720;
		menuCol.x = bg.x;
		menuCol.y = bg.y;
		add(menuCol);
		add(bg);

		//add channel graphics on here
		add(hb_bg);
		add(hb_text_small);


		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		/*
		selector.size = 40;
		selector.text = ">";
		add(selector);
		*/

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
		add(letter);
		add(bigLetter);
		add(wiiCursor);
		add(cmd_screen);
		add(cmd_text);

		if (FlxG.save.data.wii >= 1)
		{
			add(hb_big_bg);

			add(hb_water_back);
			add(hb_water);
			add(hb_big_text);

			add(hb_flash);
			add(hb_big_border);
		}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var wiiMenuState = 0;
	var wasOnMsg = false;
	var cursorSize:Float;
	var cursorOWidth:Float;
	var cmd_wait = 1;
	var cmd_ind = 0;
	var accepted = false;

	function isOnBtt(xx:Float, yy:Float, dis:Float)
	{
		var xDis = xx - FlxG.mouse.x;
		var yDis = yy - FlxG.mouse.y;
		if (Math.sqrt(Math.pow(xDis, 2) + Math.pow(yDis, 2)) < dis)
		{
			return(true);
		}
		else return(false);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;

		if (wiiMenuState == 0) accepted = controls.ACCEPT;

		if (wiiMenuState <= 1)
		{
			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			if (Main.god)
			{
				PlayState.SONG = Song.loadFromJson(songs[curSelected].songName.toLowerCase() + '-god', songs[curSelected].songName.toLowerCase());
			}
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
			accepted = false;
		}

		//wii shit
		hb_text_small.x = FlxG.width - 1280 + 130;
		hb_text_small.y = 100 + Math.cos(rot / 30) * 5;
		rot ++;
		hb_bg.alpha = hb_text_small.alpha;

		wiiCursor.x = FlxG.mouse.x;
		wiiCursor.y = FlxG.mouse.y;

		var curExt = false;
		switch (wiiMenuState)
		{
			case 0:
				if (FlxG.save.data.showLetter)
				{
					if (FlxG.save.data.wii == 0)
					{
						var onMsg = isOnBtt(FlxG.width - 100, FlxG.height - 100, 60);
						if (onMsg)
						{
							curExt = true;
							if (!wasOnMsg)
							{
								FlxG.sound.play(Paths.sound('menu/cursor'));
							}
							if (FlxG.mouse.justPressed)
							{
								FlxG.sound.play(Paths.sound('menu/select'));
								letter.alpha = 0;
								menuCol.alpha = 0;
								bg.alpha = 0.5;
								wiiMenuState = 1;
							}
						}
						wasOnMsg = onMsg;
					}
					else
					{
						var onMsg = isOnBtt(FlxG.width - 1280 + 210, 130, 120);
						if (onMsg)
						{
							curExt = true;
							if (!wasOnMsg)
							{
								FlxG.sound.play(Paths.sound('menu/cursor'));
							}
							if (FlxG.mouse.justPressed)
							{
								FlxG.sound.play(Paths.sound('menu/open'));
								FlxG.sound.music.stop();
								wiiMenuState = 3;
							}
						}
						wasOnMsg = onMsg;
					}
				}
			case 1:
				bigLetter.y += ((FlxG.height / 2 - 50) - bigLetter.y) / 3;
				if (isOnBtt(bigLetter.getMidpoint().x, bigLetter.getMidpoint().y, 65))
				{
					curExt = true;
					if (FlxG.mouse.justPressed)
					{
						FlxG.sound.music.stop();
						bigLetter.alpha = 0;
						wiiMenuState = 2;
						bg.alpha = 0;
						cmd_screen.alpha = 1;
						//grpSongs.kill();
					}
				}
			case 2:
				if (cmd_wait > 0) cmd_wait --
				else if (cmd_wait == 0)
				{
					var ltxt = cmd_text.text;
					cmd_text.text += cmd_list[cmd_ind] + '\n';
					switch (cmd_ind)
					{
						case 10:
							cmd_wait = 20;
						case 13 | 14 | 15:
							cmd_wait = 30;
						case 16 | 17:
							cmd_wait = 60;
						case 18:
							cmd_wait = 100;
						case 20:
							cmd_wait = -1;
						case 21:
							if (ltxt != '')
							{
								FlxG.switchState(new FreeplayState());
								cmd_text.text = 'aweonao';
								cmd_wait = -2;
							}
							else
							{
								cmd_wait = 100;
							}
						case 22:
							cmd_wait = 120;
						case 24:
							cmd_wait = 300;
						case 25:
							FlxG.save.data.wii = 1;
							FlxG.save.flush();
							bg.alpha = 1;
							/*
							cmd_screen.alpha = 0;
							cmd_text.kill();
							wiiMenuState = 0;
							*/
							FlxG.switchState(new FreeplayState());
						default:
							cmd_wait = 2;
					}
					cmd_ind ++;
				}
				else
				{
					if (FlxG.keys.justPressed.Y)
					{
						cmd_text.text = '';
						cmd_wait = 1;
					}
					else if (FlxG.keys.justPressed.N)
					{
						cmd_text.text = 'Installation has been cancelled.';
						cmd_wait = 200;
					}
				}
			case 3:
				//INDEX:homebrew transition
				cmd_screen.alpha += 0.01;
				hb_big_bg.alpha += 0.02;

				hb_big_size[0] += ((FlxG.width + 1) - hb_big_size[0]) / 18;
				//hb_big_size[1] += (720 - hb_big_size[1]) / 6;
				hb_big_bg.x += (0 - hb_big_bg.x) / 18;
				hb_big_bg.y += (0 - hb_big_bg.y) / 18;

				hb_big_bg.setGraphicSize(Std.int(hb_big_size[0]));
				hb_big_bg.updateHitbox();

				if (hb_big_bg.width >= FlxG.width)
				{
					wiiMenuState = 4;
					FlxG.sound.play(Paths.sound('menu/hb_jingle'));
				}
			case 4:
				switch (hb_step)
				{
					case 500:
						hb_big_text.alpha = 1;
						hb_flash.alpha = 1;
					case 940:
						curSelected = 2;
						Main.god = true;
						accepted = true;
				}

				hb_water.alpha = 1;
				hb_water_back.alpha = 1;
				var movslow = 50;
				hb_water.y += (30 - hb_water.y) / movslow;
				hb_water_back.y += (30 - hb_water.y) / movslow;

				var rotlen = 450;
				hb_water.x = -211 - rotlen + Math.sin(hb_step / 70) * rotlen;
				hb_water_back.x = -177 - rotlen + Math.sin(hb_step / 90) * rotlen;

				hb_big_text.y = Math.sin(hb_step / 60) * 20;

				if (hb_flash.alpha > 0) hb_flash.alpha -= 0.03;
				hb_step ++;
		}
		if (wiiMenuState == 3 || wiiMenuState == 4)
		{
			if (FlxG.save.data.wii >= 1)
			{
				hb_big_border.alpha = hb_big_bg.alpha;
				hb_big_border.setGraphicSize(Std.int(hb_big_bg.width));
				hb_big_border.updateHitbox();
				hb_big_border.x = hb_big_bg.x;
				hb_big_border.y = hb_big_bg.y;
			}
		}
		var cToW = cursorOWidth;
		if (curExt) cToW = cursorOWidth * 1.3;
		
		cursorSize += (cToW - cursorSize) / 3;
		wiiCursor.setGraphicSize(Std.int(cursorSize));
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 1)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 1;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = '< EASY >';
			case 2:
				diffText.text = "< HARD >";
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	var cmd_list:Array<String> = [
	'savezelda (tueidj@tueidj.net)',
	'',
	'Copyright 2008,2009 Segher Boessenkool',
	'Copyright 2008 Haxx Enterprises',
	'Copyright 2008 Hector Martin ("marcan")',
	'Copyright 2003,2004 Felix Domke',
	'',
	'This code is licensed to you under the terms of the',
	'GNU GPL, version 2; see the file COPYING',
	'',
	'Font and graphics by Fantom Larcade', //10
	'', //11
	'',
	'Cleaning up enviroment... OK.', //13
	'SD card detected', //14
	'Opening boot.elf:', //15
	'reading 2153056 bytes...', //16
	'Done.', //17
	'Valid ELF image detected.', //18
	'',
	'Install homebrew channel on this wii? [y,n]', //20
	'Downloading files...',
	'Installing the Homebrew Channel...',
	'..................................',
	'SUCCESS.',
	''
	];

	var cmd_accept:Array<String> = [
	
	];
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
