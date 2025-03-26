import {createEntityAdapter, createSlice} from "@reduxjs/toolkit";

const atlasAdapter = createEntityAdapter();

const initialState = atlasAdapter.getInitialState({
    atlas_id: null,
    title: null,
    atlas_img: null,
    images: []
})

const atlasSlice = createSlice({
    name: 'atlas',
    initialState,
    reducers: {
        setAtlas: (state, action) => {
            state.atlas_id = action.payload.atlas_id
            state.title = action.payload.title
            state.atlas_img = action.payload.atlas_img
            state.images = action.payload.images
        }
    }
})

const {actions, reducer} = atlasSlice;
export default reducer;

export const {
    setAtlas,
} = actions;


// import {createApi, fetchBaseQuery} from '@reduxjs/toolkit/query/react';
//
// export const atlasesSlice = createApi({
//
//     reducerPath: 'atlases',
//     baseQuery: fetchBaseQuery({baseUrl: 'http://localhost:3000'}),
//     tagTypes: ['Atlases'],
//     endpoints: builder => ({
//
//     })
// })