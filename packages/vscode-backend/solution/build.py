from pathlib import Path
import subprocess
import logging
import os

BUILD_COMMAND = "dts devel build --workdir {dir} -H {hostname} -f"
logging.basicConfig(level=logging.INFO)

DEFAULT_DIR = "/src/template-ros-core"
DEFAULT_LOGS = "/src/logs.txt"


def build_template_ros_core(hostname: str, directory: Path = Path(DEFAULT_DIR), log: Path = Path(DEFAULT_LOGS)) -> None:
    logging.info(f"BUILD template for hostname [{hostname}], directory [{directory}]")
    with open(log.absolute(), 'w') as file:
        # copy directory from bot to local machine
        logging.info(
            f"COPY template dir from hostname [{hostname}]")
        dir = str(directory.absolute())
        os.system(f'rm -fr {dir}/*')
        COPY_COMMAND = f'rsync --rsh="sshpass -p quackquack ssh -o StrictHostKeyChecking=no -l duckie" --archive duckie@{hostname}:/code/template-ros-core/ {dir}'
        os.system(COPY_COMMAND)
        if not directory.is_absolute():
            logging.error(f"BUILD [{str(directory.absolute())}] is not absolute:")
            raise ValueError(f"[{str(directory.absolute())}] is not absolute:")
        # build solution
        subprocess.Popen(BUILD_COMMAND.format(
            hostname=hostname,
            dir=str(directory.absolute())
        ).split(), stdout=file, stderr=file)


if __name__ == '__main__':
    build_template_ros_core("autobot10", Path("/src/template-ros-core"), Path("./logs.txt"))
