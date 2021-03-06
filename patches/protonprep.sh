#!/bin/bash

#TKG patch order:

#549 clock monotonic
#567 bypass compositor
#718 vulkan childwindow
#1044 fsync staging
#1066 fsync spincount
#1078 fs hack
#1125 rawinput
#1207 LAA
#1221 winex11-MWM
#1229 steam client swap
#1236 protonify rpc
#1237 protonify
#1239 steam bits
#1332 SDL
#1333 SDL2
#1339 gamepad additions
#1375 vr
#1386 vk bits
#1387 fs hack integer scaling
#1391 winevulkan
#1396 msvcrt native builtin
#1411 win10
#1417 dxvk_config

    cd gst-plugins-ugly
    git reset --hard HEAD
    git clean -xdf
    echo "add Guy's patch to fix wmv playback in gst-plugins-ugly"
    patch -Np1 < ../patches/gstreamer/asfdemux-always_re-initialize_metadata_and_global_metadata.patch
    patch -Np1 < ../patches/gstreamer/asfdemux-Re-initialize_demux-adapter_in_gst_asf_demux_reset.patch
    patch -Np1 < ../patches/gstreamer/asfdemux-Only_forward_SEEK_event_when_in_push_mode.patch
    patch -Np1 < ../patches/gstreamer/asfdemux-gst_asf_demux_reset_GST_FORMAT_TIME_fix.patch
    cd ..

    # warframe controller fix
    git checkout lsteamclient
    cd lsteamclient
    patch -Np1 < ../patches/proton-hotfixes/steamclient-disable_SteamController007_if_no_controller.patch
    patch -Np1 < ../patches/proton-hotfixes/steamclient-use_standard_dlopen_instead_of_the_libwine_wrappers.patch
    cd ..

    # vrclient
    git checkout vrclient_x64
    cd vrclient_x64
    patch -Np1 < ../patches/proton-hotfixes/vrclient-use_standard_dlopen_instead_of_the_libwine_wrappers.patch
    cd ..

    # VKD3D patches
    cd vkd3d
    git reset --hard HEAD
    git clean -xdf
    cd ..

    # Valve DXVK patches
    cd dxvk
    git reset --hard HEAD
    git clean -xdf
    patch -Np1 < ../patches/dxvk/valve-dxvk-avoid-spamming-log-with-requests-for-IWineD3D11Texture2D.patch
    patch -Np1 < ../patches/dxvk/proton-add_new_dxvk_config_library.patch
    patch -Np1 < ../patches/dxvk/dxvk-async.patch
    cd ..

    #WINE STAGING
    cd wine-staging
    git reset --hard HEAD
    git clean -xdf
    

    # fixes patching without rawinput
    patch -Np1 < ../patches/wine-hotfixes/staging-44d1a45-localreverts.patch    
    cd ..

    #WINE
    cd wine
    git reset --hard HEAD
    git clean -xdf

    # this conflicts with proton's gamepad changes and causes camera spinning
    git revert --no-commit da7d60bf97fb8726828e57f852e8963aacde21e9
    
    # temporary fshack reverts
#    git revert --no-commit 26b26a2e0efcb776e7b0115f15580d2507b10400
#    git revert --no-commit fd6f50c0d3e96947846ca82ed0c9bd79fd8e5b80

    
# disable these when using proton's gamepad patches
#    -W dinput-SetActionMap-genre \
#    -W dinput-axis-recalc \
#    -W dinput-joy-mappings \
#    -W dinput-reconnect-joystick \
#    -W dinput-remap-joystick \

    echo "applying staging patches"
    ../wine-staging/patches/patchinstall.sh DESTDIR="." --all \
    -W server-Desktop_Refcount \
    -W ws2_32-TransmitFile \
    -W winex11.drv-mouse-coorrds \
    -W winex11-MWM_Decorations \
    -W winex11-_NET_ACTIVE_WINDOW \
    -W winex11-WM_WINDOWPOSCHANGING \
    -W winex11-key_translation \
    -W user32-rawinput-mouse \
    -W user32-rawinput-nolegacy \
    -W user32-rawinput-mouse-experimental \
    -W user32-rawinput-hid \
    -W dinput-SetActionMap-genre \
    -W dinput-axis-recalc \
    -W dinput-joy-mappings \
    -W dinput-reconnect-joystick \
    -W dinput-remap-joystick

    #WINE FAUDIO
    #echo "applying faudio patches"
    #patch -Np1 < ../patches/faudio/faudio-ffmpeg.patch


    ### GAME PATCH SECTION ###

    #fix this
    echo "mech warrior online"
    patch -Np1 < ../patches/game-patches/mwo.patch

    echo "final fantasy XV denuvo fix"
    patch -Np1 < ../patches/game-patches/ffxv-steam-fix.patch
    
    echo "final fantasy XIV old launcher render fix"
    patch -Np1 < ../patches/game-patches/ffxiv-launcher.patch

    echo "assetto corsa"
    patch -Np1 < ../patches/game-patches/assettocorsa-hud.patch

    echo "sword art online"
    patch -Np1 < ../patches/game-patches/sword-art-online-gnutls.patch

    echo "origin downloads fix" 
    patch -Np1 < ../patches/game-patches/origin-downloads_fix.patch

    echo "fix steep"
    patch -Np1 < ../patches/wine-hotfixes/0001-Add-some-semi-stubs-in-user32.patch

    echo "Denuvo anti-cheat DOOM Eternal hotfix"
    patch -Np1 < ../patches/game-patches/gofman_dac.patch

# Currently applied but not working:

#  TODO: Add game-specific check
    echo "mk11 patch"
    patch -Np1 < ../patches/game-patches/mk11.patch

#    Disabled for now. The game uses CEG which does not work in proton.    
#    echo "blackops 2 fix"
#    patch -Np1 < ../patches/game-patches/blackops_2_fix.patch

    ### END GAME PATCH SECTION ###
    
    #PROTON

    echo "clock monotonic, amd ags"
    patch -Np1 < ../patches/proton/proton-use_clock_monotonic.patch
    patch -Np1 < ../patches/proton/proton-amd_ags.patch
    
    echo "bypass compositor"
    patch -Np1 < ../patches/proton/proton-FS_bypass_compositor.patch

    echo "applying winevulkan childwindow"
    patch -Np1 < ../patches/wine-hotfixes/winevulkan-childwindow.patch

    #WINE FSYNC
    echo "applying fsync patches"
    patch -Np1 < ../patches/proton/proton-fsync_staging.patch
    patch -Np1 < ../patches/proton/proton-fsync-spincounts.patch

#    echo "revert necessary for fshack"
#    patch -Np1 < ../patches/proton-hotfixes/wine-winex11.drv_Calculate_mask_in_X11DRV_resize_desktop.patch
    
#    echo "fullscreen hack"
#    patch -Np1 < ../patches/proton/valve_proton_fullscreen_hack-staging.patch
    
#    echo "fix for Dark Souls III, Sekiro, Nier" 
#    patch -Np1 < ../patches/game-patches/winex11_limit_resources-nmode.patch

#    echo "raw input"
#    patch -Np1 < ../patches/proton/proton-rawinput.patch
    
    echo "staging winex11-key_translation"
    patch -Np1 < ../wine-staging/patches/winex11-key_translation/0001-winex11-Match-keyboard-in-Unicode.patch
    patch -Np1 < ../wine-staging/patches/winex11-key_translation/0002-winex11-Fix-more-key-translation.patch
    patch -Np1 < ../wine-staging/patches/winex11-key_translation/0003-winex11.drv-Fix-main-Russian-keyboard-layout.patch
    
    echo "LAA"
    patch -Np1 < ../patches/proton/proton-LAA_staging.patch

#    echo "staging winex11-MWM_Decorations"
#    patch -Np1 < ../patches/proton-hotfixes/proton-staging_winex11-MWM_Decorations.patch
    
#   TODO: Fix this
    # staging winex11-_NET_ACTIVE_WINDOW - disabled, currently not working
    #patch -Np1 < ../patches/proton-hotfixes/proton-staging_winex11-_NET_ACTIVE_WINDOW.patch

#   TODO: Fix this
    # staging winex11-WM_WINDOWPOSCHANGING - disabled, currently not working
    #patch -Np1 < ../patches/proton-hotfixes/proton-staging_winex11-WM_WINDOWPOSCHANGING.patch

    echo "steamclient swap"
    patch -Np1 < ../patches/proton/proton-steamclient_swap.patch

    echo "protonify"
    patch -Np1 < ../patches/proton/proton-protonify_staging.patch

    echo "protonify-audio"
    patch -Np1 < ../patches/proton/proton-pa-staging.patch
    
    echo "steam bits"
    patch -Np1 < ../patches/proton/proton-steam-bits.patch

    echo "seccomp"
    patch -Np1 < ../patches/proton/proton-seccomp-envvar.patch

    echo "SDL Joystick"
    patch -Np1 < ../patches/proton/proton-sdl_joy.patch
    patch -Np1 < ../patches/proton/proton-sdl_joy_2.patch
    
    echo "proton gamepad additions"
    patch -Np1 < ../patches/proton/proton-gamepad-additions.patch

    echo "Valve VR patches"
    patch -Np1 < ../patches/proton/proton-vr.patch

#    echo "Valve vulkan patches"
#    patch -Np1 < ../patches/proton/proton-vk-bits-4.5.patch

#    echo "FS Hack integer scaling"
#    patch -Np1 < ../patches/proton/proton_fs_hack_integer_scaling.patch
    
#    echo "proton winevulkan"
#    patch -Np1 < ../patches/proton/proton-winevulkan.patch
    
    echo "msvcrt overrides"
    patch -Np1 < ../patches/proton/proton-msvcrt_nativebuiltin.patch

    echo "valve registry entries"
    patch -Np1 < ../patches/proton/proton-apply_LargeAddressAware_fix_for_Bayonetta.patch
    patch -Np1 < ../patches/proton/proton-Set_amd_ags_x64_to_built_in_for_Wolfenstein_2.patch
    
    echo "set prefix win10"
    patch -Np1 < ../patches/proton/proton-win10_default.patch

    echo "dxvk_config"
    patch -Np1 < ../patches/proton/proton-dxvk_config.patch

    echo "hide wine prefix update"
    patch -Np1 < ../patches/proton/proton-hide_wine_prefix_update_window.patch

    echo "applying WoW vkd3d wine patches"
    patch -Np1 < ../patches/wine-hotfixes/D3D12SerializeVersionedRootSignature.patch
    patch -Np1 < ../patches/wine-hotfixes/D3D12CreateVersionedRootSignatureDeserializer.patch

    echo "nikolay's media foundation pending patches"
    patch -Np1 < ../patches/wine-hotfixes/include-Add_IMFMediaEngineEx_definition.patch
    patch -Np1 < ../patches/wine-hotfixes/mfplat-Add_Media_Engine_attributes_to_tracing.patch
        
    echo "guy's media foundation alpha patches"
    patch -Np1 < ../patches/wine-hotfixes/media_foundation_alpha.patch
    
    echo "proton-specific manual mfplat dll register patch"
    patch -Np1 < ../patches/wine-hotfixes/proton_mediafoundation_dllreg.patch
    
    #WINE CUSTOM PATCHES
    #add your own custom patch lines below
    
    echo "Paul's Diablo 1 menu fix"
    patch -Np1 < ../patches/wine-hotfixes/user32-Set_PAINTSTRUCT_fErase_field_depending_on_the_last_WM_ERASEBKGND_result.patch
    
    echo "revert commit fd7992972b252ed262d33ef604e9e1235d2108c5 as it currently breaks a lot of games"
    patch -Np1 -R < ../patches/wine-hotfixes/fd7992972b252ed262d33ef604e9e1235d2108c5.patch

    echo "Remi's memory performance fixes"    
    patch -Np1 < ../patches/wine-hotfixes/ntdll-Use_the_free_ranges_in_find_reserved_free_area.patch
    patch -Np1 < ../patches/wine-hotfixes/makedep-Align_PE_sections_so_they_can_be_mmapped.patch

    echo "Update winemono for proton"    
    patch -Np1 < ../patches/wine-hotfixes/winemono-update_to_5.0.1.patch

    ./dlls/winevulkan/make_vulkan
    ./tools/make_requests
    autoreconf -f

    #end
