#include <ncurses.h>
//had trouble, blatantly copied from nanenj


int main()
{
    initscr();

    noecho();
    raw();

    nodelay(stdscr, true);
    keypad(stdscr, true);

    curs_set(0);

    int width, height;
    getmaxyx(stdscr,height,width); 

    int cx = 40, cy = 12;
    int c;

    while(((c=getch()))!=27)
    {
        if (c==KEY_UP && cy-1 > 0)
            cy--;
        if (c==KEY_DOWN && cy+1 < height - 1)
            cy++;
        if (c==KEY_LEFT && cx-1 > 0)
            cx--;
        if (c==KEY_RIGHT && cx+1 < width - 1)
            cx++;

        for (int x=0; x<width; x++)
        {
            for (int y=0; y<height; y++)
            {
                if (y==0)
                    mvprintw(y, x, "#");
                else if (y==height-1)
                    mvprintw(y, x, "#");
                else if (x==0)
                    mvprintw(y, x, "#");
                else if (x==width-1)
                    mvprintw(y, x, "#");
                else 
                    mvprintw(y, x, ".");
            }
            mvprintw(0, x, "#");
        }
        mvprintw(cy, cx, "@");
        refresh();
    }

    endwin();
    return 0;
}
