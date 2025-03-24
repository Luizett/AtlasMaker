import {createEntityAdapter, createSlice} from "@reduxjs/toolkit";


const sessionAdapter = createEntityAdapter();

const initialState = sessionAdapter.getInitialState({
    user_id: null,
    username: null,
    token: null
})

const sessionSlice = createSlice({
    name: 'session',
    initialState,
    reducers: {
        sessionEnter: (state, action) => {
            state.token = action.payload.token;
            state.username = action.payload.username;
            state.user_id = action.payload.user_id;
        },
        sessionLeave: (state) => {
            state.token = null;
            state.username = null;
            state.user_id = null;
        }
    }
})

const {actions, reducer} = sessionSlice;
export default reducer;

export const {
    sessionEnter,
    sessionLeave
} = actions;