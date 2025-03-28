import { configureStore } from '@reduxjs/toolkit';

// import { atlasesSlice } from './atlasesSlice';
import session from "./sessionSlice"
import user from "./userSlice"
import atlas from "./atlasSlice"

const store = configureStore({
    reducer: {session, user, atlas},
    middleware: getDefaultMiddleware => getDefaultMiddleware(),//.concat(apiSlice.middleware),
    devTools: true//process.env.NODE_ENV !== 'production'
})

export default store;