import {createApi, fetchBaseQuery} from '@reduxjs/toolkit/query/react';

export const atlasesSlice = createApi({

    reducerPath: 'atlases',
    baseQuery: fetchBaseQuery({baseUrl: 'http://localhost:3000'}),
    tagTypes: ['Atlases'],
    endpoints: builder => ({

    })
})