import React from "react";
import {useSelector} from "react-redux";
import store from "../slices/store";
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
const useFetch = () => {

    const token = window.localStorage.getItem('token');

    // if (!token) {
    //     throw new Error("No token provided")
    // }

    const headers = {
        'X-CSRF-Token': csrfToken,
        Authorization: `Bearer ${token}`
    }

    const request = async (url, method, body = null) => {

       try {
            const response = await fetch(url, {method, body, headers});

            if (!response.ok) {
                throw new Error(`Could not fetch ${url}, status: ${response.status}`);
            }
            const data = await response.json();
            if (data.error || data.errors) {
                throw new Error(`Error in request ${url}: ${data.error} ${data.errors}`)
            }
            return data;
        } catch(e) {
           throw e
            //console.log(e.message());
        }
    };

    return {request}
}

export default useFetch
