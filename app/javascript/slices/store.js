import { configureStore } from '@reduxjs/toolkit';

// import { atlasesSlice } from './atlasesSlice';
import session from "./sessionSlice"

const store = configureStore({
    reducer: {session},
       // [apiSlice.reducerPath]: apiSlice.reducer},
    middleware: getDefaultMiddleware => getDefaultMiddleware(),//.concat(apiSlice.middleware),
    devTools: true//process.env.NODE_ENV !== 'production'
})

export default store;