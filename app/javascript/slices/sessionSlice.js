import {createEntityAdapter, createSlice} from "@reduxjs/toolkit";

const sessionAdapter = createEntityAdapter();

const initialState = sessionAdapter.getInitialState({
    token: null
})



const sessionSlice = createSlice({
    name: 'session',
    initialState,
    reducers: {
        sessionEnter: (state, action) => {
            state.token = action.payload;
        },
        sessionLeave: (state) => {
            state.token = null;
        }
    }
})

const {actions, reducer} = sessionSlice;
export default reducer;

export const {
    sessionEnter,
    sessionLeave
} = actions;