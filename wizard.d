#!/usr/bin/rdmd
import std.stdio;
import std.string;
import deimos.ncurses;

pragma(lib, "ncurses");

enum playerChar = "@";

void main()
{   
    int c;
    int y, x;
    bool cont = true; 
    
    
    initscr();
	noecho();
    cbreak();	
    keypad(stdscr, true);
    start_color();
    getmaxyx(stdscr, y, x);
    
    init_pair(1, COLOR_RED, COLOR_BLACK);
    attron(COLOR_PAIR(1));
    
    Player player = Player(playerChar, y/2, x/2);
    player.print;
    
    c = getch();
    while(cont)
    {
        c = getch();
        if(c == 'j' || c == KEY_DOWN)
            player.down;
        else if(c == 'k' || c == KEY_UP)
            player.up;
        else if(c == 'l' || c == KEY_RIGHT)
            player.right;
        else if(c == 'h' || c == KEY_LEFT)
            player.left;
        else if(c == 'q')
            cont = false;
        else 
            printw("That's not movement...");
        clear();
        player.print;
    }
    endwin();
}

struct Player
{
    string  c;
    int     xpos;
    int     ypos;

    this(string character, int yt, int xt)
    {
        c = character;
        xpos = xt;
        ypos = yt;
    }

    @property pure void up()
    {   ypos--; }
    @property pure void down()
    {   ypos++; }
    @property pure void left()
    {   xpos--; }
    @property pure void right()
    {   xpos++; }
    @property void print()
    {   mvprintw(ypos, xpos, c.toStringz()); }
}
