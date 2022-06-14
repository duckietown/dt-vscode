import subprocess
import logging
logging.basicConfig(level=logging.INFO)

SOFT_STOP_COMMAND = "docker -H {hostname} stop -t 2 dts-run-template-ros-core"
HARD_STOP_COMMAND = "docker -H {hostname}    restart -t 1 duckiebot-interface"


def stop_template_ros_core(hostname: str) -> None:
    logging.info(f"STOP bot with hostname \"{hostname}\"")
    print(HARD_STOP_COMMAND.format(
        hostname=hostname
    ))
    subprocess.Popen(SOFT_STOP_COMMAND.format(
        hostname=hostname
    ).split())
    subprocess.Popen(HARD_STOP_COMMAND.format(
        hostname=hostname
    ).split())
