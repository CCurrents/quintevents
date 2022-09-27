/**
 * Created by joshlequire1 on 9/19/22.
 */

// First, checks if it isn't implemented yet.
if (!String.prototype.format) {
    String.prototype.format = function () {
        var args = arguments;
        return this.replace(/{(\d+)}/g, function (match, number) {
            return typeof args[number] != 'undefined'
                ? args[number]
                : match
                ;
        });
    };
}

const getMessageFromErrorObject = (err) => {
    let errorMsg = 'Unknown Error';

    if (err) {
        if (Array.isArray(err.body)) {
            errorMsg = err.body.map(e => e.message).join(', ');
        } else if (typeof err.body.message === 'string') {
            errorMsg = err.body.message;
        }
    }

    return errorMsg;
}

const logToTable = (proxyObject) => {
    console.table(stripProxy(proxyObject));
}

const stripProxy = (proxyObject) => {
    return JSON.parse(JSON.stringify(proxyObject));
}

const sleep = (milliseconds) => {
    return new Promise(resolve => setTimeout(resolve, milliseconds))
}

export {
    getMessageFromErrorObject,
    logToTable,
    stripProxy,
    sleep
}