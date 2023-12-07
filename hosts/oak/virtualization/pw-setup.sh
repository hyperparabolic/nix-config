#!/usr/bin/env bash

pw-cli ls | grep 'win10-out' > /dev/null

if [ $? != 0 ] ; then
  echo "Pipewire: initializing win10-out"
  # create adapter
  pw-cli create-node adapter '{ factory.name=support.null-audio-sink node.name=win10-out media.class=Audio/Sink object.linger=true audio.position=[FL FR] }'
  # link to device
  pw-link "win10-out:monitor_FL" "alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.analog-stereo:playback_FL"
  pw-link "win10-out:monitor_FR" "alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.analog-stereo:playback_FR"
else
  echo "Pipewire: win10-out previously initialized, skipping init."
fi


pw-cli ls | grep 'win10-in' > /dev/null

if [ $? != 0 ] ; then
  echo "Pipewire: initializing win10-in"
  # create adapter
  pw-cli create-node adapter '{ factory.name=support.null-audio-sink node.name=win10-in media.class=Audio/Source/Virtual object.linger=true audio.position=[FL FR] }'
  # link to device
  pw-link "alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.analog-stereo:capture_FL" "win10-in:input_FL"
  pw-link "alsa_input.usb-Focusrite_Scarlett_2i2_USB_Y86BTH519C4572-00.analog-stereo:capture_FR" "win10-in:input_FR"
else
  echo "Pipewire: win10-in previously initialized, skipping init."
fi

