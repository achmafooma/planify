/*
* Copyright © 2023 Alain M. (https://github.com/alainm23/planify)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alainmh23@gmail.com>
*/

// we have to inject '#undef interface' because Windows has a macro "interface" that breaks the builds!
[CCode (cfile = "", has_header = false)]
extern void _vala_undef_interface_macro_1 ();

[CCode (cfile = "#undef interface", has_header = false)]
extern void _vala_undef_interface_macro_2 ();


// Class containing hookups to Win32 API calls and public functions to access them
public class Win32Util {

    // for the windows URL opener
    [CCode (
        cname = "ShellExecuteA",
        dll = "shell32.dll",
        has_header = false
    )]
    private extern static void* _url_opener (
        void* hwnd,
        string? operation,
        string file,
        string? parameters,
        string? directory,
        int show_cmd
    );
    public static void url_opener (string url) throws Error {
        void* result = _url_opener(null, "open", url, null, null, 1);
        long code = (long) result;
        if (code <= 32) {
            // Wrap the Windows error code in a GLib.Error
            throw new GLib.Error (
                GLib.Quark.from_string ("util-open-url"),
                (int) code,
                "Failed to open URL '%s' (ShellExecute returned %ld)",
                url,
                code
            );
        }
    }

    // for the Windows dark/light mode toggle
    private const int DWMWA_USE_IMMERSIVE_DARK_MODE = 20;

    [CCode (cname = "DwmSetWindowAttribute", dll = "dwmapi.dll", has_header = false)]
    private extern static int _set_dark_theme (
        void* hwnd,
        int attribute,
        void* attribute_value,
        int attribute_size
    );
    public static void set_dark_theme (void* hwnd, bool enabled) {
        // BOOL in Win32 is a 32‑bit int
        int dark = enabled ? 1 : 0;

        _set_dark_theme (
            hwnd,
            DWMWA_USE_IMMERSIVE_DARK_MODE,
            &dark,
            (int) sizeof (int)
        );
    }


    [CCode (cname = "LoadLibraryA", dll = "kernel32.dll", has_header = false)]
    private extern static void* LoadLibrary (string name);

    [CCode (cname = "GetProcAddress", dll = "kernel32.dll", has_header = false)]
    private extern static void* GetProcAddress (void* module, void* ordinal);

    private static void* ordinal (int value) {
        return (void*) (ulong) value;
    }

    [CCode (has_target = false)]
    private delegate bool ShouldSystemUseDarkModeDelegate ();

    private static ShouldSystemUseDarkModeDelegate? should_system_dark = null;

    private static void ensure_uxtheme_loaded () {
        if (should_system_dark != null)
            return;

        void* mod = LoadLibrary ("uxtheme.dll");
        if (mod == null)
            return;

        // Ordinal 132 (always works)
        void* proc = GetProcAddress (mod, ordinal (132));

        if (proc != null)
            should_system_dark = (ShouldSystemUseDarkModeDelegate) proc;
    }

    public static bool system_is_dark_theme () {
        ensure_uxtheme_loaded ();

        if (should_system_dark == null)
            return false; // fallback on light mode if we can't figure out system setting

        return should_system_dark ();
    }


    // Get a valid Windows HWND
    [CCode (
        cname = "gdk_win32_surface_get_handle",
        cheader_filename = "",
        cfile = "gdk/win32/gdkwin32.h",
        has_header = false
    )]
    public extern static void* get_hwnd (Gdk.Surface surface);

}
