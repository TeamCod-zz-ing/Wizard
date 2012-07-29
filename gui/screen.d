module gui.screen;

import deimos.ncurses;
import std.string: toStringz;
pragma(lib, "ncurses");

//run this with rdmd -debug -I../ screen.d
class Screen
{
    WinInfo Map;
    WinInfo Log;
    WinInfo Stat;
    int yMax;
    int xMax;

    this()
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
    {   endwin(); }

    void newMap(int height = LINES-4, int width = COLS-30, int startY = 0, int startX = 0)
    {
        Map = WinInfo(height, width, startY, startX);
        
        Map.create;
    }
    void newLog(int height = 4, int width = COLS-30, int startY = LINES-4, int startX = 0) 
    {   
        Log = WinInfo(height, width, startY, startX); //newwin(4, COLS-30, LINES-4, 0);    
        Log.create;
    }
    void newStat(int height = LINES, int width = 30, int startY = 0, int startX = COLS-30)
    {
        Stat = WinInfo(height, width, startY, startX);
        Stat.create;
    }
}

struct WinInfo
{
    int height;
    int width;
    int startY;
    int startX;
    WINDOW* ptr;
    
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
        box(ptr, A_NORMAL, A_NORMAL);

        ptr.wrefresh();
    }
    void print(string str)
    {   mvwprintw(ptr, 1, 1, "%s", str.toStringz()); 
        ptr.wrefresh(); 
    }
}
debug mixin(
`
import std.stdio;

void main()
{
    Screen one = new Screen();
    one.newMap();
    one.newLog();
    one.newStat();
    one.Map.print("Hello Map World!");
    one.Log.print("Hello Log World!");
    one.Stat.print("Hello Stat World!");
    refresh();
    getch();
}
`);
