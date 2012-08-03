module gui.screen;

import deimos.curses.ncurses;
import std.string: toStringz;
import std.conv;
import std.array;
pragma(lib, "ncurses");


extern (C) :
//run this with rdmd -debug -I../ screen.d
struct Screen
{
    map_t Map;
    log_t Log;
    status_t Stat;
    int yMax;
    int xMax;

    this(bool t)
    {   if(t)
            init();
    }


    void init()
    {
        initscr();
        cbreak();
        noecho();    

        keypad(stdscr, true);
        start_color();
        curs_set(0);
        
        getmaxyx(stdscr, yMax, xMax);

        refresh();
    }
    ~this()
    {   cleanUp();  }

    void newMap(int height = LINES-8, int width = COLS-30, int startY = 0, int startX = 0)
    {
        Map = map_t(height, width, startY, startX);
    }
    void newLog(int height = 8, int width = COLS-30, int startY = LINES-8, int startX = 0) 
    {   
        Log = log_t(height, width, startY, startX);     
    }
    void newStat(int height = LINES, int width = 30, int startY = 0, int startX = COLS-30)
    {
        Stat = status_t(height, width, startY, startX);
    }
    void cleanUp()
    {   endwin();   }
}


    
struct map_t
{
    WinInfo     win;
public:
    chtype[][]  map; 

    this(int h, int w, int y, int x)
    {
        win = WinInfo(h, w, y, x);
        win.create;
    }
    
    
    void print(string str, size_t yVal, size_t xVal)
    {    
        win.print(str, yVal, xVal);
    }

    bool canMove(int ypos, int xpos)
    {   return true; }

}

struct log_t
{
    WinInfo     win;
public:
    size_t      index; 
    string[]    history;// = Appender!(string[])();
    this(int h, int w, int y, int x)
    {
        history.length = 1;
        win = WinInfo(h, w, y, x);
        win.create;
    }
    
    void push(string temp)
    {   
        /*
         *if(history.length>6)
         *{
         *    history[history.length] = temp;
         *    index = 6;
         *    foreach(str; history[$..$-6])
         *    { 
         *        win.print(str, index-1, 1);
         *    }
         *}
         *else
         */

        history[0] = temp;

        if(history.length>1)
            foreach(i, str; history[$..$-6])
            { 
                win.print(str, i, 1); 
            }
        else
            win.print(history[0], 1, 1);
        //history.length++; 
        //win.print(history[history.length-1], history.length, 1);
    }
    
    void test() 
    {
        if(index == 1)
            push("history index updated successfully: ");
        else
            win.print("Error on History Index", 1, 1);
    }
}

struct status_t
{
    WinInfo win;
public:
    string  name;
    uint    HP;
    uint    MP;

    ubyte   Str;
    ubyte   Int;
    ubyte   Dex;
    ubyte   Luck;

    this(int h, int w, int y, int x)
    {
        win = WinInfo(h, w, y, x);
        win.create;
        string[56]  history;
    }
    void line(string t, size_t i)
    {
        name = t;
        win.print(t, i, 1);
    }
}

struct WinInfo
{
    
    WINDOW* ptr;
    int height;
    int width;
    int startY;
    int startX;
    
    this(int h, int w, int y, int x)
    {
        height = h;
        width = w;
        startY = y;
        startX = x;
    }

    @property void create()
    {
        ptr = newwin(height, width, startY, startX);
        drawBox(); 
    }
    @property drawBox()
    {
        ptr.box(A_NORMAL, A_NORMAL);
        ptr.wrefresh();
    }
    @property void scrollOk()
    {
        ptr.scrollok(true);
        ptr.wrefresh();
    }
    void print(string str, size_t yVal, size_t xVal)
    {   mvwprintw(ptr, cast(int)yVal, cast(int)xVal, "%s", str.toStringz()); 
        ptr.wrefresh(); 
    }
}

extern (D) :
debug mixin(`
import std.stdio;

void main()
{
    writeln("Beginning Screen Initialization");
    Screen one = Screen(true);
//
//  These 'space holders' are so the compiler will know which line
//  That the errors occur on.
//
    one.newMap();
    one.newLog();
    one.newStat();
//
    //Print some things to the screen
    //Also a minor explination of the API
    //Log is a circular buffer, so you push it
    //We initiale Scrolling first, this may become automatic 
    one.Log.push("Hello Log World!");
    one.Log.push("Added Example to Log");
    getch();
    one.Log.push("Initialized Scrolling in Log");
// 
    //Stat is a way to add LINES-2-(log) lines to the 
    //screen. So I'm not yet defining anything really high
    //level here, just convienience functions really
    one.Stat.line("Hello Stat World!",  1);
    one.Stat.line("Name :  Jude",       2);
    one.Stat.line("Class:  Wizard (duh)", 3);
    one.Stat.line("HP   :  9/11",       5);
    one.Stat.line("MP   :  11/13",      6);
    one.Stat.line("Str  :  10",         7);
    one.Stat.line("Int  :  12",         8);
    one.Stat.line("Wis  :  7",          9);
    one.Stat.line("Wizard Needs food badly!", 11);
    one.Log.push("Added Example to Stat"); //debugging code
//
//  Map is under construction...
//  But here's what I have:
    one.Map.print("Hello Map world!", 1, 1);
    one.Log.push("Added Example to Map");
    one.Log.push("Is refresh even Needed?");
    one.Log.push("And another string to test log scrolling");
    getch();
    writeln("Test ended without fail");
}
`);
