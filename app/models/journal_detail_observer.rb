# find status transitions where we want to do stuff!
class JournalDetailObserver < ActiveRecord::Observer

  def after_create(journal_detail)
    printed_status = IssueStatus.where(name: "Printed").first

    if (journal_detail.journal.journalized_type == "Issue") && journal_detail.journal.journalized.poster.present? #if there is a poster involved, going deep here!
      if (journal_detail.property == "attr") && (journal_detail.prop_key == "status_id")
        if journal_detail.value == printed_status.id
          Mailer.poster_printed(journal_detail.journal.journalized.poster).deliver
        end
      end
    end
  end

end
