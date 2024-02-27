from pwnagotchi.ui.components import LabeledValue
from pwnagotchi.ui.view import BLACK
import pwnagotchi.ui.fonts as fonts
import pwnagotchi.plugins as plugins
import logging
import os


class DisplayPassword(plugins.Plugin):
    __author__ = "@nagy_craig"
    __version__ = "1.0.0"
    __license__ = "GPL3"
    __description__ = "A plugin to display recently cracked passwords"

    def on_loaded(self):
        logging.info("display-password loaded")

    def on_ui_setup(self, ui):
        try:
<<<<<<< Updated upstream
            if self.options["position_x"] and self.options["position_y"]:
                h_pos = self.options["h_pos"].split(",")
                v_pos = self.options["v_pos"].split(",")
||||||| Stash base
            if self.options["position_x"] and self.options["position_y"]:
                h_pos = (self.options["position_x"], self.options["position_y"])
                v_pos = (self.options["position_x"], self.options["position_y"])
=======
            if self.options["h_pos"] or self.options["v_pos"]:
                h_pos = self.options["h_pos"].split(",")
                v_pos = self.options["v_pos"].split(",")
>>>>>>> Stashed changes
            elif ui.is_waveshare_v2():
                h_pos = (0, 95)
                v_pos = (180, 61)
            elif ui.is_waveshare_v1():
                h_pos = (0, 95)
                v_pos = (170, 61)
            elif ui.is_waveshare144lcd():
                h_pos = (0, 92)
                v_pos = (78, 67)
            elif ui.is_inky():
                h_pos = (0, 83)
                v_pos = (165, 54)
            elif ui.is_waveshare2in7():
                h_pos = (0, 153)
                v_pos = (216, 122)
            elif ui.is_waveshare1in54V2():
                h_pos = (0, 92)
                v_pos = (70, 170)
            else:
                h_pos = (0, 91)
                v_pos = (180, 61)

            if self.options["orientation"] == "vertical":
                selected_position = v_pos
            else:
                selected_position = h_pos
            ui.add_element(
                "display-password",
                LabeledValue(
                    color=BLACK,
                    label="",
                    value="",
                    position=selected_position,
                    label_font=fonts.Bold,
                    text_font=fonts.Small,
                ),
            )
        except Exception as e:
            logging.error(f"[DISPLAY-PASSWORD] {e}")

    def on_unload(self, ui):
        try:
            with ui._lock:
                ui.remove_element("display-password")
        except Exception as e:
            logging.error(f"[DISPLAY-PASSWORD] {e}")

    def on_ui_update(self, ui):
        logging.debug("[DISPLAY-PASSWORD] Actualizando UI")
        try:
            for file in os.listdir("/root/handshakes"):
                if file.endswith(".potfile"):
                    with open(f'/root/handshakes/{file}', 'r') as file:
                        lines = file.readlines()
                        if len(lines) > 0:
                            last_line = lines[-1].split(":")[2:]
                            last_line = ":".join(last_line)
                            ui.set("display-password", f"{last_line}")
        except Exception as e:
            logging.error(f"[DISPLAY-PASSWORD] {e}")
