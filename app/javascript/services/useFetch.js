import React from "react";
import {useSelector} from "react-redux";

const useFetch = () => {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const {token} = useSelector(state => state.session);
    const headers = {
        'X-CSRF-Token': csrfToken,
        Authorization: `Bearer ${token}`
    }

    const request = async (url, method, body) => {

        try {
            const response = await fetch(url, {method, body, headers});

            if (!response.ok) {
                throw new Error(`Could not fetch ${url}, status: ${response.status}`);
            }

            return await response.json();
        } catch(e) {
            throw e;
        }
    };

    return {request}
}

export default useFetch
