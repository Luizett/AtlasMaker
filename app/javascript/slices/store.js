import { configureStore } from '@reduxjs/toolkit';

// import { atlasesSlice } from './atlasesSlice';

const store = configureStore({
    reducer: {[apiSlice.reducerPath]: apiSlice.reducer},
    middleware: getDefaultMiddleware => getDefaultMiddleware().concat(apiSlice.middleware),
    devTools: true//process.env.NODE_ENV !== 'production'
})

export default store;