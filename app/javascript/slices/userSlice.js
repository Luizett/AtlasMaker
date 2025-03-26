import {createEntityAdapter, createSlice} from "@reduxjs/toolkit";

const userAdapter = createEntityAdapter();

const initialState = userAdapter.getInitialState({
    user_id: null,
    username: null,
    avatar: null
})
// todo добавить внутри редьюсеров соответсвующие запросы к серверу...?
const userSlice = createSlice({
    name: 'user',
    initialState,
    reducers: {
        setAll: (state, action) => {
            state.user_id = action.payload.user_id
            state.username = action.payload.username
            state.avatar = action.payload.avatar
        },
        resetAll: (state) => {
            state.user_id = null
            state.username = null
            state.avatar = null
        },
        changeUsername: (state, action) => {
            state.username = action.payload;
        },
        changeAvatar: (state, action) => {
            state.avatar = action.payload;
        }
    }
})

const {actions, reducer} = userSlice;
export default reducer;

export const {
    setAll,
    resetAll,
    changeUsername,
    changeAvatar
} = actions;