LIBDIR=$DEST/neutron/devstack/lib

source $LIBDIR/l2_agent
source $LIBDIR/l2_agent_sriovnicswitch
source $LIBDIR/ml2
source $LIBDIR/qos

if [[ "$1" == "stack" ]]; then
    case "$2" in
        install)
            if is_service_enabled q-qos; then
                configure_qos
            fi
            ;;
        post-config)
            if is_service_enabled q-agt; then
                configure_l2_agent
            fi
            #Note: sriov agent should run with OVS or linux bridge agent
            #because they are the mechanisms that bind the DHCP and router ports.
            #Currently devstack lacks the option to run two agents on the same node.
            #Therefore we create new service, q-sriov-agt, and the q-agt should be OVS
            #or linux bridge.
            if is_service_enabled q-sriov-agt; then
                configure_$Q_PLUGIN
                configure_l2_agent
                configure_l2_agent_sriovnicswitch
            fi
            ;;
        extra)
            if is_service_enabled q-sriov-agt; then
                start_l2_agent_sriov
            fi
            ;;
    esac
elif [[ "$1" == "unstack" ]]; then
    if is_service_enabled q-sriov-agt; then
        stop_l2_agent_sriov
    fi
fi