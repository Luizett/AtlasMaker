import {createEntityAdapter, createSlice} from "@reduxjs/toolkit";

const atlasAdapter = createEntityAdapter();

const initialState = atlasAdapter.getInitialState({
    atlas_id: null,
    title: null,
    atlas_img: null
})

const atlasSlice = createSlice({
    name: 'atlas',
    initialState,
    reducers: {
        setAtlas: (state, action) => {
            state.atlas_id = action.payload.atlas_id
            state.title = action.payload.title
            state.atlas_img = action.payload.atlas_img
        },
        resetAtlas: (state) => {
            state.atlas_id = null
            state.title = null
            state.atlas_img =null
        }
    }
})

const {actions, reducer} = atlasSlice;
export default reducer;

export const {
    setAtlas,
    resetAtlas
} = actions;

