import React, { useEffect, useState, useCallback } from 'react';
import { StyleSheet, View, Text, FlatList, ActivityIndicator } from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import { SafeAreaView } from 'react-native-safe-area-context';
import { fetchCoins } from './index';
import { AppDispatch } from '../../store/index';

const CoinScreen = () => {
  const coins = useSelector((state) => state.coins.list);
  const isLoading = useSelector((state) => state.coins.isLoading);
  const isRefreshing = useSelector((state) => state.coins.isRefreshing);
  const hasMore = useSelector((state) => state.coins.hasMore);
  const currentPage = useSelector((state) => state.coins.currentPage);
  const dispatch = useDispatch<AppDispatch>();

  useEffect(() => {
    const params = {currentPage: currentPage};
    dispatch(fetchCoins(params));
  }, [dispatch]);

  const handleRefresh = useCallback(() => {
    if (!isRefreshing) {
      const params = {currentPage: 1, isRefreshing: true};
      dispatch(fetchCoins(params));
    }
  }, [isRefreshing]);

  const handleLoadMore = useCallback(() => {
    if (!hasMore) {
      const params = {currentPage: currentPage + 1, hasMore: true};
      dispatch(fetchCoins(params));
    } 
  }, [hasMore, currentPage]);
  const renderItem = ({ item }) => (
    <View style={styles.item}>
      <Text style={styles.name}>{`${item.rank}. ${item.name}`}</Text>
      <Text style={styles.symbol}>{`$${item.priceUsd}`}</Text>
    </View>
  );

  const renderFooter = () =>
    isLoading && hasMore ? (
      <View style={styles.footer}>
        <ActivityIndicator size="small" />
      </View>
    ) : null;

  return (
    <SafeAreaView edges={['top', 'bottom']}>
      <FlatList
        data={coins}
        renderItem={renderItem}
        keyExtractor={(item) => item.id}
        onRefresh={handleRefresh}
        refreshing={isRefreshing}
        onEndReached={handleLoadMore}
        onEndReachedThreshold={0.1}
        scrollEventThrottle={16}
        ListFooterComponent={renderFooter}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  item: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#ccc',
  },
  name: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  symbol: {
    fontSize: 16,
    color: '#777',
  },
  footer: {
    paddingVertical: 20,
    borderTopWidth: 1,
    borderTopColor: '#ccc',
  },
});

export default CoinScreen;