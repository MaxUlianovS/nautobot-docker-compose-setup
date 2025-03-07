"""nornir dispatcher for Fortinet"""

from nornir_nautobot.plugins.tasks.dispatcher.default import (
    # NapalmDefault,
    NetmikoDefault,
)


class FortinetNetmikoDispatcher(NetmikoDefault):
    """Collection of Netmiko Nornir Tasks"""

    config_command = "show full-configuration"
