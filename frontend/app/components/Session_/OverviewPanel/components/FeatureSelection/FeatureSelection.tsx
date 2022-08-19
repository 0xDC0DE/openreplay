import React from 'react';
import { Checkbox, Popup } from 'UI';

const NETWORK = 'NETWORK';
const ERRORS = 'ERRORS';
const EVENTS = 'EVENTS';
const CLICKRAGE = 'CLICKRAGE';
const PERFORMANCE = 'PERFORMANCE';

interface Props {
    list: any[];
    updateList: any;
}
function FeatureSelection(props: Props) {
    const { list } = props;
    const features = [NETWORK, ERRORS, EVENTS, CLICKRAGE, PERFORMANCE];
    const disabled = list.length >= 3;

    return (
        <React.Fragment>
            {features.map((feature, index) => {
                const checked = list.includes(feature);
                const _disabled = disabled && !checked;
                return (
                    <Popup content="X-RAY supports up to 3 views" disabled={!_disabled} delay={0}>
                        <Checkbox
                            key={index}
                            label={feature}
                            checked={checked}
                            className="mx-4"
                            disabled={_disabled}
                            onClick={() => {
                                if (checked) {
                                    props.updateList(list.filter((item: any) => item !== feature));
                                } else {
                                    props.updateList([...list, feature]);
                                }
                        }}
                    />
                    </Popup>
                );
            })}
        </React.Fragment>
    );
}

export default FeatureSelection;
