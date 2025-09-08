class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform
    # Marcar carrinhos como abandonados após 3 horas sem interação
    abandoned_carts_count = mark_abandoned_carts
    
    # Remover carrinhos abandonados há mais de 7 dias
    removed_carts_count = remove_old_abandoned_carts
    
    Rails.logger.info "Marked #{abandoned_carts_count} carts as abandoned"
    Rails.logger.info "Removed #{removed_carts_count} old abandoned carts"
    
    {
      marked_as_abandoned: abandoned_carts_count,
      removed_carts: removed_carts_count
    }
  end

  private

  def mark_abandoned_carts
    carts_to_abandon = Cart.not_abandoned
                          .where('last_interaction_at < ?', 3.hours.ago)
                          .where.not(last_interaction_at: nil)
    
    count = carts_to_abandon.count
    carts_to_abandon.update_all(abandoned: true, updated_at: Time.current)
    count
  end

  def remove_old_abandoned_carts
    old_abandoned_carts = Cart.abandoned
                             .where('last_interaction_at < ?', 7.days.ago)
                             .where.not(last_interaction_at: nil)
    
    count = old_abandoned_carts.count
    old_abandoned_carts.destroy_all
    count
  end
end
