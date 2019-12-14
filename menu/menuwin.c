#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <signal.h>

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

/* need some shutdown signal handler */
uint signals=0;
uint shutdown_signals [] = {1,2,3,4,6,10,11,12,14,15};
uint shutdown_signals_ored;
int max_signo = sizeof(uint)*sizeof(char) * 8 ; 

void shutdown(int signo)
{	
	if (signo > max_signo ) return;
	signals = 1 << signo;
	if ( signals || shutdown_signals_ored ){
		fprintf(stderr,"exiting because of signal: %i\n",signo);
		XUnmapWindow (menu_box.display, menu_box.window);
		exit(signo);
	}
}

void init_shutdown_signals()
{
	for (int i=0;i < sizeof(shutdown_signals)/sizeof(uint);i++){
	shutdown_signals_ored|= shutdown_signals[i];
	if (signal(shutdown_signals[i], shutdown ) == SIG_ERR ){
		fprintf(stderr,"WARNING: can not register signal \"%i\"\n",shutdown_signals[i]);
	}
	}
}

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

static void create_window (int w,int h,int x, int y)
{
    menu_box.width = w;
    menu_box.height = h;
    menu_box.window = 
        XCreateSimpleWindow (menu_box.display,
                             menu_box.root,
                             x, /* x */
                             y, /* y */
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

//argv:= (int w,int h,int x, int y) 
int main (int argc, char ** argv)
{
    x_class_hints=XAllocClassHint();
    x_class_hints->res_name="menuwin";
    x_class_hints->res_class="menuwin";
    x_connect ();
    create_window (atoi(argv[1]),atoi(argv[2]),atoi(argv[3]),atoi(argv[4]));
    XSetClassHint(menu_box.display, menu_box.window, x_class_hints);
	init_shutdown_signals();
    event_loop ();
    return 0;
}
