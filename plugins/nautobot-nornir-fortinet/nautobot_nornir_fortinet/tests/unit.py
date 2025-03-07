import pytest

from nautobot_nornir_fortinet.plugins.tasks.dispatcher.fortinet import (
    FortinetNetmikoDispatcher,
)

from nornir_nautobot.plugins.tasks.dispatcher.default import (
    # NapalmDefault,
    NetmikoDefault,
)


def test_fortinet_netmiko_dispatcher_initialization():
    dispatcher = FortinetNetmikoDispatcher()
    assert isinstance(dispatcher, FortinetNetmikoDispatcher)
    assert issubclass(FortinetNetmikoDispatcher, NetmikoDefault)


def test_config_command():
    dispatcher = FortinetNetmikoDispatcher()
    assert dispatcher.config_command == "show full-configuration"


@pytest.mark.parametrize("driver_name", ["fortinet", "fortigate", "fortimanager"])
def test_driver_name_resolution(driver_name):
    dispatcher = FortinetNetmikoDispatcher()
    assert dispatcher.driver(driver_name) == "fortinet"


def test_invalid_driver_name():
    dispatcher = FortinetNetmikoDispatcher()
    with pytest.raises(ValueError):
        dispatcher.driver("invalid_driver")
