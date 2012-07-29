#!/usr/bin/env rdmd
//Above is ignored by the compiler, it allows 'script'-like 
//features. in other words, ./wizard.d will work if wizard.d is executable
//below: import a few things..
import std.stdio; //needed only for the debug statement below
import std.string: toStringz; //selective import, only needed for toStringz mentioned below
//The path and import path are important.
import deimos.curses.ncurses; //we aren't using menu or anything else
//version is a lovely feature. It'll compile the below code only if
//the below exists and is defined by the compiler.
//It would allow for a demo version and a release version to be the same code
version(DigitalMars)
{
//compiler directive. basically, this will cause this to be assumed
//rdmd -L-lncurses
//this does not work with gdc or ldc. Only dmd. which is why we check for 
//dmd with the version(DigitalMars) above
    pragma(lib, "ncurses");
}
//enums are a storage class.  It will figure out the type for me.
//Also enums are used to force Compile Time Function Evaluation.
//They MUST know the input at compile time.
//also, strings are different in D. they are defined as immutable(char)[] 
//or arrays of immutable chars.  Immutable is a storage class as well.
//immutable is a much stronger const. It will throw an error if an attempt is 
//made to change the var. Sounds useless for a string, but it applies only to the
//chars.  You may change the string as a whole, or not at all.
//arrays are special in that they are dynamic, and know their own length.
//string.length will tell you the length of a string. you may also alter the
//length with string.length = 5 
//"@" is a C-style string, it has \0 appended to the end.
enum playerChar = "@";
int y, x;
//void main does what you'd assume
void main()
{   
    chtype c; //ncurses specific type, any printable character. in other words, uint
    //auto keyword figures out the return type for you.
    //bad code style below, auto should not be applied to everything
    //meaninglessly.  It can obfuscate the code. I just wanted to throw in an example
    auto cont = true; 
    
    initscr();
	noecho();
    cbreak();	
    keypad(stdscr, true);
    start_color();
    curs_set(0);
    getmaxyx(stdscr, y, x);
    
    addBackground('.');
    addWalls();

    //Below, Player(string, int, int) must match an existing this() inside Player. 
    //otherwise the default this() is called
    Player player = Player(playerChar, y/2, x/2);
    player.print;
    
    //while loops may not contain assignment.
    while(cont)
    {
        c = getch();
        //debug code is only compiled if -debug switch is called, dmd -debug
        debug writeln("input is: ", c);
        if(c == 'j' || c == KEY_DOWN) //allow either vim-style movement, or arrow keys
            player.down;
        else if(c == 'k' || c == KEY_UP)
            player.up;
        else if(c == 'l' || c == KEY_RIGHT)
            player.right;
        else if(c == 'h' || c == KEY_LEFT)
            player.left;
        else if(c == 'q') //exit when q is pressed
            cont = false;
        clear();
        addBackground();
        addWalls();
        player.print;
    }
    //This is interesting, and possibly bad code.
    //basically, upon exit, run this before you exit.
    //It's an easy way to automatically call cleanup code.
    scope(exit) endwin();
}

void addBackground(chtype c = '.')
{   
    foreach(i; 1..COLS-1)
        foreach(j; 1..LINES-1)
            mvaddch(j, i, c);
}

void addWalls(chtype c = ACS_CKBOARD) 
{
    foreach(tempx; 0..COLS)
        foreach(tempy; 0..LINES)
        {
            if(tempx == 0 || tempy == 0) 
                mvaddch(tempy, tempx, c);
            if(tempx == COLS-1 || tempy == LINES-1)
                mvaddch(tempy, tempx, c);
        } 
}


//structs are created on the stack.
//classes are on the heap.
struct Player
{
    //Variables in D are automatically initialized with their default values.
    //This prevents stupid errors where vars are created but not initialized.
    string  c;      //initialized to empty, i believe
    int     xpos;   //int, ubyte, short, and long(and unsigned versions) are initialized to 0
    int     ypos;   //floating point variables are initialized to NaN(NotaNumber), or in other words, nonsense.

    //constructor, Allows me to define the default values.
    this(string character, int yt, int xt)
    {
        c = character;
        xpos = xt;
        ypos = yt;
    }
    //@property means that it is called like this Player.up; no parens necessary
    //pure means that this affects nothing other than Player. It allows optimizations
    //to occur which would not be possible to assume otherwise.
    //functions are only pure if they have no global side effects. The outcome of up() 
    //should only depend on its input. you should always get the same result from the same input.
    //No system calls are made as a result of anything a pure function does.
    //This is checked by the compiler.
    //@property may come before or after the name
    pure void up()      @property
    {   ypos--; }
    pure void down()    @property
    {   ypos++; }
    pure void left()    @property
    {   xpos--; }
    pure void right()   @property
    {   xpos++; }
    //This calls mvprintw, which calls system code. It cannot be pure.
    //toStringz makes a copy of a D string, adds '\0' to the end, casts to char*
    //returns the result. So it basically turns a D string into a C string
    //Oh! D allows Universal function calling. x.foo() == foo(x), x.foo(y) == foo(x, y);
    void print()        @property
    {   attron(A_REVERSE); 
        mvprintw(ypos, xpos, c.toStringz()); 
        attroff(A_REVERSE); 
    }
//only used when compiled with -unittest, otherwise ignored
//you may throw errors when a unittest fails with assert
//useful to have all of the tests in the same file as the actual code
    unittest
    {
    //do nothing. Just an example
    }
}
