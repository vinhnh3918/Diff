import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

const API_URL = 'https://api.coincap.io/v2/assets';

export const fetchCoins = createAsyncThunk('coins/fetchCoins', async (params: any ) => {
  const {
    currentPage = 1,
  } = params
  const limit = 15 * currentPage;
  const response = await fetch(`${API_URL}?limit=${limit}`);
  const data = await response.json();
  return { coins: data.data || [] };
});

const coinsSlice = createSlice({
  name: 'coins',
  initialState: {
    list: [],
    isLoading: false,
    isRefreshing: false,
    hasMore: false,
    currentPage: 1,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchCoins.pending, (state, action) => {
        if (!action.meta.arg.isRefreshing) {
          state.isLoading = true;
        } else {
          state.isRefreshing = true;
          state.currentPage = 1;
        }
        if (!action.meta.arg.hasMore) {
          state.isLoading = true;
        } else {
          state.hasMore = true;
          state.currentPage = state.currentPage + 1;
        }
      })
      .addCase(fetchCoins.fulfilled, (state, action) => {
        state.list = action.payload.coins;
        state.hasMore = false;
        state.isLoading = false;
        state.isRefreshing = false;
      })
      .addCase(fetchCoins.rejected, (state) => {
        state.hasMore = false;
        state.isLoading = false;
        state.isRefreshing = false;
      });
  },
});

export default coinsSlice.reducer;