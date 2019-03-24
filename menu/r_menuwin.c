#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

/* The window which contains the text. */

struct {
    int width;
    int height;

    /* X Windows related variables. */

    Display * display;
    int screen;
    Window root;
    Window window;
    unsigned long black_pixel;    
    unsigned long white_pixel;
}
menu_box;


XClassHint * x_class_hints; 

/* Connect to the display, set up the basic variables. */

static void x_connect ()
{
    menu_box.display = XOpenDisplay (NULL);
    if (! menu_box.display) {
        fprintf (stderr, "Could not open display.\n");
        exit (1);
    }
    menu_box.screen = DefaultScreen (menu_box.display);
    menu_box.root = RootWindow (menu_box.display, menu_box.screen);
    menu_box.black_pixel = BlackPixel (menu_box.display, menu_box.screen);
    menu_box.white_pixel = WhitePixel (menu_box.display, menu_box.screen);
}

/* Create the window. */

static void create_window ()
{
    menu_box.width = 1850;
    menu_box.height = 1080;
    menu_box.window = 
        XCreateSimpleWindow (menu_box.display,
                             menu_box.root,
                             1281, /* x */
                             0, /* y */
                             menu_box.width,
                             menu_box.height,
                             0, /* border width */
                             menu_box.black_pixel, /* border pixel */
                             menu_box.black_pixel  /* background */);
    XMapWindow (menu_box.display, menu_box.window);
}

static void event_loop ()
{
    Atom wm_delete_window;
    wm_delete_window = XInternAtom (menu_box.display, "WM_DELETE_WINDOW", False);
    XSetWMProtocols (menu_box.display, menu_box.window, &wm_delete_window, 1);

    while (1) {
        XEvent e;
        XNextEvent (menu_box.display, & e);
        if (e.type == ClientMessage) {
            if ((Atom)e.xclient.data.l[0] == wm_delete_window) {
                break;
            }
        }
    }
}


int main (int argc, char ** argv)
{
    x_class_hints=XAllocClassHint();
    x_class_hints->res_name="menuwin";
    x_class_hints->res_class="menuwin";
    x_connect ();
    create_window ();
    XSetClassHint(menu_box.display, menu_box.window, x_class_hints);
    event_loop ();
    return 0;
}
